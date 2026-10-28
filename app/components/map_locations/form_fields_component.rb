# typed: strict
class MapLocations::FormFieldsComponent < ApplicationComponent
  sig { returns(ActionView::Helpers::FormBuilder) }
  attr_reader :form

  sig { returns(MapLocation) }
  attr_reader :map_location

  delegate :render_map, to: :helpers

  sig { params(form: ActionView::Helpers::FormBuilder, map_location: MapLocation).void }
  def initialize(form, map_location:)
    @form = form
    @map_location = map_location
  end

  sig { returns(T.nilable(String)) }
  def render?
    feature?(:map)
  end

  private

    sig { returns(String) }
    def label
      t("proposals.form.map_location")
    end

    sig { returns(String) }
    def help
      t("proposals.form.map_location_instructions")
    end
end
