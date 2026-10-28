# typed: strict
class Admin::Stats::BudgetBallotingComponent < ApplicationComponent
  sig { returns(Budget) }
  attr_reader :budget

  delegate :include_stat_graphs_javascript, to: :helpers

  sig { params(budget: Budget).void }
  def initialize(budget)
    @budget = budget
    @stats = T.let(nil, T.nilable(Budget::Stats))
    @headings_stats = T.let(nil, T.nilable(T::Hash[T.any(Integer, Symbol), T::Hash[Symbol, T.untyped]]))
  end

  private

    sig { returns(Budget::Stats) }
    def stats
      @stats ||= Budget::Stats.new(budget, cache: false)
    end

    sig { returns(T::Hash[T.any(Integer, Symbol), T::Hash[Symbol, T.untyped]]) }
    def headings_stats
      @headings_stats ||= stats.headings
    end

    sig { returns(Integer) }
    def vote_count
      stats.total_votes
    end

    sig { returns(Integer) }
    def user_count
      stats.total_participants_vote_phase
    end

    sig { returns(T::Array[[T.untyped, Integer]]) }
    def vote_count_by_heading
      budget.lines.group(:heading_id).count.map { |k, v| [Budget::Heading.find(k).name, v] }.sort
    end

    sig { returns(T::Array[[T.untyped, T.untyped]]) }
    def user_count_by_heading
      budget.headings.map do |heading|
        [heading.name, T.must(headings_stats[heading.id])[:total_participants_vote_phase]]
      end.select { |_, count| count > 0 }.sort
    end
end
