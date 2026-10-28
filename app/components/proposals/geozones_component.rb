# typed: strict
class Proposals::GeozonesComponent < ApplicationComponent
  delegate :image_path_for, to: :helpers

  sig { returns(T::Boolean) }
  def render?
    Geozone.any?
  end
end
