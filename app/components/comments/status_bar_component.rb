# typed: strict
class Comments::StatusBarComponent < ApplicationComponent
  sig { returns(Comment) }
  attr_reader :comment

  sig { returns(T::Boolean) }
  attr_reader :valuation

  delegate :comments_closed_for_commentable?, :require_verified_resident_for_commentable?, to: :helpers

  sig { params(comment: Comment, valuation: T::Boolean).void }
  def initialize(comment, valuation:)
    @comment = comment
    @valuation = valuation
  end

  private

    sig { returns(String) }
    def link_text
      if T.let(comment, T.nilable(Comment)).present?
        t("comments_helper.reply_link")
      else
        t("comments_helper.comment_link")
      end
    end

    sig { returns(T.untyped) }
    def can_comment?
      current_user &&
        !comments_closed_for_commentable?(comment.commentable) &&
        !require_verified_resident_for_commentable?(comment.commentable, current_user)
    end
end
