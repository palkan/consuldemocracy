# typed: strict
module ImageAttributes
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ActionController::Base }

  sig { returns(T::Array[Symbol]) }
  def image_attributes
    [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy]
  end
end
