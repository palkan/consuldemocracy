# typed: strict
class Shared::MapLocationComponent < ApplicationComponent
  sig { returns(T.nilable(T::Array[T::Hash[Symbol, T.untyped]])) }
  attr_reader :investments_coordinates, :geozones_data

  sig { returns(T.nilable(ActionView::Helpers::FormBuilder)) }
  attr_reader :form

  sig do
    params(
      map_location: T.nilable(MapLocation),
      investments_coordinates: T.nilable(T::Array[T::Hash[Symbol, T.untyped]]),
      form: T.nilable(ActionView::Helpers::FormBuilder),
      geozones_data: T.nilable(T::Array[T::Hash[Symbol, T.untyped]])
    ).void
  end
  def initialize(map_location, investments_coordinates: nil, form: nil, geozones_data: nil)
    @map_location = map_location
    @investments_coordinates = investments_coordinates
    @form = form
    @geozones_data = geozones_data
  end

  sig { returns(MapLocation) }
  def map_location
    @map_location ||= MapLocation.new
  end

  private

    sig { returns(T::Boolean) }
    def editable?
      form.present?
    end

    sig { returns(T::Boolean) }
    def show_remove_marker_button?
      editable? && map_location.mappable.present?
    end

    sig { returns(T.nilable(T.any(Float, String))) }
    def latitude
      map_location.latitude.presence || Setting["map.latitude"]
    end

    sig { returns(T.nilable(T.any(Float, String))) }
    def longitude
      map_location.longitude.presence || Setting["map.longitude"]
    end

    sig { returns(T.nilable(T.any(Integer, String))) }
    def zoom
      map_location.zoom.presence || Setting["map.zoom"]
    end

    sig { returns(String) }
    def remove_marker_label
      t("proposals.form.map_remove_marker")
    end

    sig { returns(String) }
    def remove_marker_id
      "remove-marker-#{dom_id(map_location)}"
    end

    sig { returns(ActiveSupport::SafeBuffer) }
    def remove_marker
      button_tag remove_marker_label,
                 id: remove_marker_id,
                 class: "map-location-remove-marker",
                 type: "button"
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def data
      {
        map: "",
        map_center_latitude: latitude,
        map_center_longitude: longitude,
        map_zoom: zoom,
        map_tiles_provider: Rails.application.secrets[:map_tiles_provider],
        map_tiles_provider_attribution: Rails.application.secrets[:map_tiles_provider_attribution],
        marker_editable: editable?,
        marker_remove_selector: "##{remove_marker_id}",
        marker_investments_coordinates: investments_coordinates,
        marker_latitude: map_location.latitude.presence,
        marker_longitude: map_location.longitude.presence,
        marker_title: marker_coordinates_text,
        marker_clustering: feature?("map.feature.marker_clustering"),
        geozones: geozones_data
      }.merge(input_selectors)
    end

    sig { returns(T.nilable(String)) }
    def marker_coordinates_text
      return unless map_location.available?

      t("proposals.form.map_marker_coordinates",
        latitude: map_location.latitude,
        longitude: map_location.longitude)
    end

    sig { returns(T::Hash[Symbol, String]) }
    def input_selectors
      if form
        {
          latitude_input_selector: "##{input_id(:latitude)}",
          longitude_input_selector: "##{input_id(:longitude)}",
          zoom_input_selector: "##{input_id(:zoom)}"
        }
      else
        {}
      end
    end

    sig { params(attribute: Symbol).returns(String) }
    def input_id(attribute)
      T.must(form).hidden_field(attribute).match(/ id="([^"]+)"/)[1]
    end
end
