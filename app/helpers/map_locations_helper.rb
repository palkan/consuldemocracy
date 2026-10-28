# typed: strict
module MapLocationsHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params(map_location: T.nilable(MapLocation)).returns(T::Boolean) }
  def map_location_available?(map_location)
    map_location.present? && map_location.available?
  end

  sig { params(map_location: T.nilable(MapLocation), "**": T.untyped).returns(ActiveSupport::SafeBuffer) }
  def render_map(map_location, **)
    render Shared::MapLocationComponent.new(map_location, **)
  end
end
