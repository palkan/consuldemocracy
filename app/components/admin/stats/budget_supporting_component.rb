# typed: strict
class Admin::Stats::BudgetSupportingComponent < ApplicationComponent
  sig { returns(Budget) }
  attr_reader :budget

  delegate :include_stat_graphs_javascript, to: :helpers

  sig { params(budget: Budget).void }
  def initialize(budget)
    @budget = budget
    @stats = T.let(nil, T.nilable(Budget::Stats))
    @headings_stats = T.let(nil, T.nilable(T::Hash[T.any(Integer, Symbol), T::Hash[Symbol, T.untyped]]))
    @chart = T.let(nil, T.nilable(Ahoy::Chart))
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
      stats.total_supports
    end

    sig { returns(Integer) }
    def user_count
      stats.total_participants_support_phase
    end

    sig { returns(T::Array[[Budget::Heading, T.untyped]]) }
    def user_count_by_heading
      budget.headings.map do |heading|
        [heading, T.must(headings_stats[heading.id])[:total_participants_support_phase]]
      end
    end

    sig { returns(Ahoy::Chart) }
    def chart
      @chart ||= Ahoy::Chart.new("budget_investment_supported")
    end
end
