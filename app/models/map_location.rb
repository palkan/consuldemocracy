# typed: strict
class MapLocation < ApplicationRecord
  belongs_to :proposal, touch: true
  belongs_to :investment, class_name: "Budget::Investment", touch: true

  validates :longitude, :latitude, :zoom, presence: true, numericality: true

  sig { returns(T::Boolean) }
  def available?
    latitude.present? && longitude.present? && zoom.present?
  end

  sig { returns(T.nilable(T.any(Proposal, Budget::Investment))) }
  def mappable
    proposal || investment
  end

  sig { returns(T.nilable(String)) }
  def title
    mappable&.title
  end

  sig { params(heading: Budget::Heading).returns(MapLocation) }
  def self.from_heading(heading)
    new(
      zoom: Budget::Heading::OSM_DISTRICT_LEVEL_ZOOM,
      latitude: heading.latitude.presence&.to_f,
      longitude: heading.longitude.presence&.to_f
    )
  end

  sig do
    params(
      investments: T.any(
        Budget::Investment::PrivateRelation,
        Budget::Investment::PrivateAssociationRelation,
        Budget::Investment::PrivateCollectionProxy
      )
    ).returns(T::Array[T::Hash[Symbol, T.untyped]])
  end
  def self.investments_json_data(investments)
    return [] if investments.none?

    budget_id = T.must(investments.first).budget_id

    data = investments.joins(:map_location)
                      .with_fallback_translation
                      .pluck(:id, :title, :latitude, :longitude)

    data.map do |values|
      {
        title: values[1],
        link: "/budgets/#{budget_id}/investments/#{values[0]}",
        lat: values[2],
        long: values[3]
      }
    end
  end
end
