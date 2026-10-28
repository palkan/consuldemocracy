# typed: strict
module DocumentAttributes
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ActionController::Base }

  sig { returns(T::Array[Symbol]) }
  def document_attributes
    [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy]
  end
end
