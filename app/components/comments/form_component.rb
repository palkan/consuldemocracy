# typed: strict
class Comments::FormComponent < ApplicationComponent
  sig { returns(T.untyped) }
  attr_reader :commentable

  sig { returns(T.nilable(Integer)) }
  attr_reader :parent_id

  sig { returns(T::Boolean) }
  attr_reader :valuation

  delegate :locale_and_user_status, :commentable_cache_key,
           :comments_closed_for_commentable?, :require_verified_resident_for_commentable?,
           :link_to_verify_account, :parent_or_commentable_dom_id, :leave_comment_text,
           :comment_button_text, to: :helpers

  sig { params(commentable: T.untyped, parent_id: T.nilable(Integer), valuation: T::Boolean).void }
  def initialize(commentable, parent_id: nil, valuation: false)
    @commentable = commentable
    @parent_id = parent_id
    @valuation = valuation
  end

  private

    sig { returns(T::Array[T.untyped]) }
    def cache_key
      [
        locale_and_user_status,
        parent_id,
        commentable_cache_key(commentable),
        valuation
      ]
    end

    sig { returns(String) }
    def comments_closed_text
      if commentable.class == Legislation::Question
        t("legislation.questions.comments.comments_closed")
      else
        t("comments.comments_closed")
      end
    end
end
