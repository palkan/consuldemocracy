# typed: strict
class Admin::Settings::MapTabComponent < ApplicationComponent
  sig { returns(String) }
  def tab
    "#tab-map-configuration"
  end

  sig { returns(T::Array[String]) }
  def settings
    %w[
      map.latitude
      map.longitude
      map.zoom
    ]
  end
end
