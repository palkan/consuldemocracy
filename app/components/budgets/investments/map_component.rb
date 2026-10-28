# typed: strict
class Budgets::Investments::MapComponent < ApplicationComponent
  sig { returns(T.nilable(Budget::Heading)) }
  attr_reader :heading

  sig { returns(T.any(Budget::Investment::PrivateRelation, Budget::Investment::PrivateAssociationRelation)) }
  attr_reader :investments

  delegate :render_map, to: :helpers

  sig do
    params(
      investments: T.any(Budget::Investment::PrivateRelation, Budget::Investment::PrivateAssociationRelation),
      heading: T.nilable(Budget::Heading)
    ).void
  end
  def initialize(investments, heading:)
    @investments = investments
    @heading = heading
  end

  sig { returns(T.nilable(T::Boolean)) }
  def render?
    map_location&.available?
  end

  private

    sig { returns(T.nilable(MapLocation)) }
    def map_location
      MapLocation.from_heading(T.must(heading)) if heading.present?
    end

    sig { returns(T::Array[T::Hash[Symbol, T.untyped]]) }
    def coordinates
      MapLocation.investments_json_data(investments.unscope(:order))
    end

    sig { returns(T.nilable(T::Array[T::Hash[Symbol, T.untyped]])) }
    def geozones_data
      heading = T.must(self.heading)
      return if heading.geozone.blank?

      geozone = T.must(heading.geozone)

      [
        {
          outline_points: geozone.outline_points,
          color: geozone.color,
          name: heading.name
        }
      ]
    end
end
