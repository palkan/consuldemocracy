# typed: strict
module GeozonesHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params(geozonable: T.untyped).returns(T.nilable(String)) }
  def geozone_name(geozonable)
    geozonable.geozone ? geozonable.geozone.name : t("geozones.none")
  end

  sig { returns(T::Array[[T.nilable(String), Integer]]) }
  def geozone_select_options
    Geozone.order(name: :asc).map { |g| [g.name, g.id] }
  end
end
