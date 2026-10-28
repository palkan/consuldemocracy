# typed: strict
class Geozone < ApplicationRecord
  include Graphqlable

  attribute :color, default: "#0000ff"

  has_many :proposals
  has_many :debates
  has_many :users
  has_many :headings, class_name: "Budget::Heading", dependent: :nullify
  validates :name, presence: true
  validates :geojson, geojson_format: true

  scope :public_for_api, -> { all }

  sig { returns(T::Array[T.nilable(String)]) }
  def self.names
    Geozone.pluck(:name)
  end

  sig { returns(T::Boolean) }
  def safe_to_destroy?
    Geozone.reflect_on_all_associations(:has_many).all? do |association|
      association.klass.where(geozone: self).empty?
    end
  end

  sig { returns(T.nilable(String)) }
  def outline_points
    normalized_geojson&.to_json
  end

  private

    sig { returns(T.nilable(T::Hash[T.untyped, T.untyped])) }
    def normalized_geojson
      if geojson.present?
        parsed_geojson = JSON.parse(T.must(geojson))

        if parsed_geojson["type"] == "FeatureCollection"
          parsed_geojson["features"].each do |feature|
            feature["properties"] ||= {}
          end

          parsed_geojson
        elsif parsed_geojson["type"] == "Feature"
          parsed_geojson["properties"] ||= {}

          wrap_in_feature_collection(parsed_geojson)
        elsif parsed_geojson["geometry"]
          parsed_geojson["properties"] ||= {}

          wrap_in_feature_collection(wrap_in_feature(parsed_geojson["geometry"]))
        elsif parsed_geojson["type"] && parsed_geojson["coordinates"]
          wrap_in_feature_collection(wrap_in_feature(parsed_geojson))
        else
          raise ArgumentError, "Invalid GeoJSON fragment"
        end
      end
    end

    sig { params(geometry: T.untyped).returns(T::Hash[Symbol, T.untyped]) }
    def wrap_in_feature(geometry)
      {
        type: "Feature",
        geometry: geometry,
        properties: {}
      }
    end

    sig { params(feature: T::Hash[T.untyped, T.untyped]).returns(T::Hash[Symbol, T.untyped]) }
    def wrap_in_feature_collection(feature)
      {
        type: "FeatureCollection",
        features: [feature]
      }
    end
end
