# typed: strict
class Polls::AdvancedStatsComponent < ApplicationComponent
  sig { returns(Poll::Stats) }
  attr_reader :stats

  delegate :number_to_stats_percentage, to: :helpers

  sig { params(stats: Poll::Stats).void }
  def initialize(stats)
    @stats = stats
  end

  sig { returns(T.nilable(T::Boolean)) }
  def render?
    stats.advanced?
  end

  sig { params(number: Numeric, percentage: Numeric).returns(ActiveSupport::SafeBuffer) }
  def number_with_percentage(number, percentage)
    safe_join([number, tag.small { tag.em("(#{number_to_stats_percentage(percentage)})") }], " ")
  end
end
