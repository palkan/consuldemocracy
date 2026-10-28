# typed: strict
class Admin::Stats::ChartComponent < ApplicationComponent
  sig { returns(Ahoy::Chart) }
  attr_reader :chart

  sig { params(chart: Ahoy::Chart).void }
  def initialize(chart)
    @chart = chart
  end

  private

    sig { returns(Integer) }
    def count
      chart.count
    end

    sig { returns(T.any(String, Symbol)) }
    def event
      chart.event_name
    end

    sig { returns(ActiveSupport::SafeBuffer) }
    def chart_tag
      tag.div("data-graph": chart.data_points.to_json)
    end

    sig { returns(String) }
    def title
      "#{chart.title} (#{count})"
    end
end
