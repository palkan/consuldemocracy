# typed: strict
class Budgets::MapComponent < ApplicationComponent
  delegate :render_map, to: :helpers

  sig { returns(Budget) }
  attr_reader :budget

  sig { params(budget: Budget).void }
  def initialize(budget)
    @budget = budget
  end

  sig { returns(T.nilable(T::Boolean)) }
  def render?
    feature?(:map) && !budget.informing?
  end

  private

    sig { returns(T::Array[T::Hash[Symbol, T.untyped]]) }
    def coordinates
      if budget.publishing_prices_or_later? && budget.investments.selected.any?
        investments = budget.investments.selected
      else
        investments = budget.investments
      end

      MapLocation.investments_json_data(investments)
    end

    sig { returns(T::Array[T::Hash[Symbol, T.untyped]]) }
    def geozones_data
      budget.geozones.map do |geozone|
        {
          outline_points: geozone.outline_points,
          color: geozone.color,
          headings: geozone_headings(geozone).map do |heading|
            link_to heading.name, budget_investments_path(budget, heading_id: heading.id)
          end,
          name: geozone_headings(geozone).map(&:name).join(", ")
        }
      end
    end

    sig { params(geozone: Geozone).returns(Budget::Heading::PrivateAssociationRelation) }
    def geozone_headings(geozone)
      budget.headings.where(geozone: geozone)
    end
end
