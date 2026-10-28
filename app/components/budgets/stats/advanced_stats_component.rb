# typed: strict
class Budgets::Stats::AdvancedStatsComponent < ApplicationComponent
  sig { returns(Budget::Stats) }
  attr_reader :stats

  delegate :number_with_info_tags, :number_to_stats_percentage, to: :helpers

  sig { params(stats: Budget::Stats).void }
  def initialize(stats)
    @stats = stats
  end

  sig { returns(T.nilable(T::Boolean)) }
  def render?
    stats.advanced?
  end

  private

    sig { returns(T::Array[Budget::Heading]) }
    def headings
      stats.budget.headings.sort_by_name
    end
end
