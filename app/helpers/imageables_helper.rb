# typed: strict
module ImageablesHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params(imageable: Budget::Investment).returns(T::Boolean) }
  def can_destroy_image?(imageable)
    imageable.image.present? && can?(:destroy, imageable.image)
  end
end
