# typed: strict
class Admin::Geozones::FormComponent < ApplicationComponent
  sig { returns(Geozone) }
  attr_reader :geozone

  sig { params(geozone: Geozone).void }
  def initialize(geozone)
    @geozone = geozone
  end
end
