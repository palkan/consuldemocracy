# typed: strict
class Admin::Stats::EventLinksComponent < ApplicationComponent
  sig { returns(T::Array[T.any(String, Symbol)]) }
  attr_reader :event_names

  delegate :link_list, to: :helpers

  sig { params(event_names: T::Array[T.any(String, Symbol)]).void }
  def initialize(event_names)
    @event_names = event_names
  end

  private

    sig { params(event: T.any(String, Symbol)).returns(String) }
    def link_text(event)
      Ahoy::Chart.new(event).title
    end

    sig { returns(T::Array[[String, String]]) }
    def links
      event_names.map do |event|
        [link_text(event), graph_admin_stats_path(event: event)]
      end
    end
end
