# typed: strict
class Admin::Stats::GlobalChartComponent < ApplicationComponent
  private

    sig { returns(T::Array[Symbol]) }
    def event_names
      Ahoy::Chart.active_event_names
    end

    sig { returns(ActiveSupport::SafeBuffer) }
    def chart_tag
      tag.div("data-graph": data_points.to_json)
    end

    sig { returns(T::Hash[T.any(Symbol, String), T::Array[T.untyped]]) }
    def data_points
      Ahoy::Chart.active_events_data_points
    end

    sig { returns(String) }
    def title
      t("admin.stats.graph.title")
    end
end
