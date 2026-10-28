# typed: strict
module MapLocationAttributes
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ActionController::Base }

  sig { returns(T::Array[Symbol]) }
  def map_location_attributes
    [:latitude, :longitude, :zoom]
  end
end
