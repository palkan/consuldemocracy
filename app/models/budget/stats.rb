# typed: strict
class Budget::Stats
  include Statisticable
  extend T::Sig

  sig { returns(Budget) }
  def budget
    T.cast(resource, Budget)
  end

  sig { returns(T::Array[Symbol]) }
  def self.stats_methods
    super + support_phase_methods + vote_phase_methods
  end

  sig { returns(T::Array[Symbol]) }
  def self.support_phase_methods
    %i[total_participants_support_phase total_budget_investments
       total_selected_investments total_unfeasible_investments headings]
  end

  sig { returns(T::Array[Symbol]) }
  def self.vote_phase_methods
    %i[total_votes total_participants_vote_phase]
  end

  sig { returns(T::Array[Symbol]) }
  def stats_methods
    base_stats_methods + participation_methods + phase_methods
  end

  sig { returns(T::Array[String]) }
  def phases
    %w[support vote].select { |phase| send("#{phase}_phase_finished?") }
  end

  sig { returns(T::Array[String]) }
  def all_phases
    return phases unless phases.many?

    [*phases, "every"]
  end

  sig { returns(T.nilable(T::Boolean)) }
  def support_phase_finished?
    budget.valuating_or_later?
  end

  sig { returns(T::Boolean) }
  def vote_phase_finished?
    budget.finished?
  end

  sig { returns(T.nilable(ActiveSupport::TimeWithZone)) }
  def participation_date
    send("#{phases.last}_phase_participation_date")
  end

  sig { returns(Integer) }
  def total_participants
    participants.distinct.count
  end

  sig { returns(Integer) }
  def total_participants_support_phase
    voters.count
  end

  sig { returns(Integer) }
  def total_participants_vote_phase
    (balloters + poll_ballot_voters).uniq.count
  end

  sig { returns(Integer) }
  def total_budget_investments
    budget.investments.count
  end

  sig { returns(Integer) }
  def total_supports
    supports(budget).count
  end

  sig { returns(Integer) }
  def total_votes
    budget.ballots.pluck(:ballot_lines_count).sum
  end

  sig { returns(Integer) }
  def total_selected_investments
    budget.investments.selected.count
  end

  sig { returns(Integer) }
  def total_unfeasible_investments
    budget.investments.unfeasible.count
  end

  sig { returns(T::Hash[T.any(Integer, Symbol), T::Hash[Symbol, T.any(Integer, Float, String)]]) }
  def headings
    groups = Hash.new(0)
    budget.headings.order(:id).each do |heading|
      groups[heading.id] = Hash.new(0).merge(calculate_heading_totals(heading))
    end

    groups[:total] = Hash.new(0)
    groups[:total][:total_investments_count] = groups.sum { |_k, v| v[:total_investments_count] }
    groups[:total][:total_participants_support_phase] = groups.sum { |_k, v| v[:total_participants_support_phase] }
    groups[:total][:total_participants_vote_phase] = groups.sum { |_k, v| v[:total_participants_vote_phase] }
    groups[:total][:total_participants_every_phase] = groups.sum { |_k, v| v[:total_participants_every_phase] }

    budget.headings.each do |heading|
      groups[heading.id].merge!(calculate_heading_stats_with_totals(groups[heading.id], groups[:total], heading.population))
    end

    groups[:total][:percentage_participants_support_phase] = groups.sum { |_k, v| v[:percentage_participants_support_phase] }
    groups[:total][:percentage_participants_vote_phase] = groups.sum { |_k, v| v[:percentage_participants_vote_phase] }
    groups[:total][:percentage_participants_every_phase] = groups.sum { |_k, v| v[:percentage_participants_every_phase] }

    groups
  end

  private

    sig { returns(T::Array[Symbol]) }
    def phase_methods
      phases.map { |phase| self.class.send("#{phase}_phase_methods") }.flatten
    end

    sig { returns(T.nilable(ActiveSupport::TimeWithZone)) }
    def support_phase_participation_date
      T.must(budget.phases.selecting).ends_at
    end

    sig { returns(T.nilable(ActiveSupport::TimeWithZone)) }
    def vote_phase_participation_date
      T.must(budget.phases.balloting).ends_at
    end

    sig { returns(T::Array[Integer]) }
    def participant_ids
      phases.map { |phase| send("participant_ids_#{phase}_phase") }.flatten.uniq
    end

    sig { returns(T::Array[Integer]) }
    def participant_ids_support_phase
      (authors + voters).uniq
    end

    sig { returns(T::Array[Integer]) }
    def participant_ids_vote_phase
      (balloters + poll_ballot_voters).uniq
    end

    sig { returns(T::Array[Integer]) }
    def authors
      @authors ||= T.let(budget.investments.pluck(:author_id), T.nilable(T::Array[Integer]))
    end

    sig { returns(T::Array[Integer]) }
    def voters
      @voters ||= T.let(supports(budget).distinct.pluck(:voter_id), T.nilable(T::Array[Integer]))
    end

    sig { returns(T::Array[Integer]) }
    def balloters
      @balloters ||= T.let(budget.ballots.where(ballot_lines_count: 1..).distinct.pluck(:user_id).compact,
                           T.nilable(T::Array[Integer]))
    end

    sig { returns(T::Array[Integer]) }
    def poll_ballot_voters
      poll = budget.poll
      @poll_ballot_voters ||= T.let(poll ? poll.voters.pluck(:user_id) : [], T.nilable(T::Array[Integer]))
    end

    sig { params(heading_id: Integer).returns(T::Array[Integer]) }
    def balloters_by_heading(heading_id)
      stats_cache("balloters_by_heading_#{heading_id}") do
        budget.ballots.joins(:lines)
              .where(budget_ballot_lines: { heading_id: heading_id })
              .distinct.pluck(:user_id)
      end
    end

    sig { params(heading: Budget::Heading).returns(T::Array[Integer]) }
    def voters_by_heading(heading)
      stats_cache("voters_by_heading_#{heading.id}") do
        supports(heading).distinct.pluck(:voter_id)
      end
    end

    sig { params(heading: Budget::Heading).returns(T::Hash[Symbol, Integer]) }
    def calculate_heading_totals(heading)
      {
        total_investments_count: heading.investments.count,
        total_participants_support_phase: voters_by_heading(heading).count,
        total_participants_vote_phase: balloters_by_heading(heading.id).count,
        total_participants_every_phase: voters_and_balloters_by_heading(heading)
      }
    end

    sig do
      params(
        heading_totals: T::Hash[Symbol, T.untyped],
        groups_totals: T::Hash[Symbol, T.untyped],
        population: T.nilable(Integer)
      ).returns(T::Hash[Symbol, T.any(Float, String)])
    end
    def calculate_heading_stats_with_totals(heading_totals, groups_totals, population)
      {
        percentage_participants_support_phase: participants_percent(heading_totals, groups_totals, :total_participants_support_phase),
        percentage_district_population_support_phase: population_percent(population, heading_totals[:total_participants_support_phase]),
        percentage_participants_vote_phase: participants_percent(heading_totals, groups_totals, :total_participants_vote_phase),
        percentage_district_population_vote_phase: population_percent(population, heading_totals[:total_participants_vote_phase]),
        percentage_participants_every_phase: participants_percent(heading_totals, groups_totals, :total_participants_every_phase),
        percentage_district_population_every_phase: population_percent(population, heading_totals[:total_participants_every_phase])
      }
    end

    sig { params(heading: Budget::Heading).returns(Integer) }
    def voters_and_balloters_by_heading(heading)
      (voters_by_heading(heading) + balloters_by_heading(heading.id)).uniq.count
    end

    sig do
      params(
        heading_totals: T::Hash[Symbol, T.untyped],
        groups_totals: T::Hash[Symbol, T.untyped],
        phase: Symbol
      ).returns(Float)
    end
    def participants_percent(heading_totals, groups_totals, phase)
      calculate_percentage(heading_totals[phase], groups_totals[phase])
    end

    sig { params(population: T.nilable(Integer), participants: Integer).returns(T.any(Float, String)) }
    def population_percent(population, participants)
      return "N/A" unless population.to_f.positive?

      calculate_percentage(participants, T.must(population))
    end

    sig { params(supportable: T.any(Budget, Budget::Heading)).returns(Vote::PrivateRelation) }
    def supports(supportable)
      Vote.where(votable: supportable.investments)
    end

    stats_methods.each { |method_name| stats_cache(method_name) }

    sig { params(key: T.any(String, Symbol)).returns(String) }
    def full_cache_key_for(key)
      "budgets_stats/#{budget.id}/#{phases.join}/#{key}"
    end
end
