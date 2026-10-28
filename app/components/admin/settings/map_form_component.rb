# typed: strict
class Admin::Settings::MapFormComponent < ApplicationComponent
  sig { returns(T.nilable(String)) }
  attr_reader :tab

  delegate :render_map, to: :helpers

  sig { params(tab: T.nilable(String)).void }
  def initialize(tab: nil)
    @tab = tab
  end

  private

    sig { returns(MapLocation) }
    def map_location
      MapLocation.new(
        latitude: Setting["map.latitude"],
        longitude: Setting["map.longitude"],
        zoom: Setting["map.zoom"]
      )
    end
end
