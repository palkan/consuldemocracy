# typed: strict
class Admin::Geozones::IndexComponent < ApplicationComponent
  include Header

  sig { returns(T.any(Geozone::PrivateRelation, T::Array[Geozone])) }
  attr_reader :geozones

  delegate :render_map, to: :helpers

  sig { params(geozones: T.any(Geozone::PrivateRelation, T::Array[Geozone])).void }
  def initialize(geozones)
    @geozones = geozones
  end

  private

    sig { override.returns(String) }
    def title
      t("admin.geozones.index.title")
    end

    sig { params(condition: T.untyped).returns(String) }
    def yes_no_text(condition)
      if condition
        t("shared.yes")
      else
        t("shared.no")
      end
    end

    sig { returns(T::Array[T::Hash[Symbol, T.untyped]]) }
    def geozones_data
      geozones.map do |geozone|
        {
          outline_points: geozone.outline_points,
          color: geozone.color,
          headings: [link_to(geozone.name, edit_admin_geozone_path(geozone))],
          name: geozone.name
        }
      end
    end
end
