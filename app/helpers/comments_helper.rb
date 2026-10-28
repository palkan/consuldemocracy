# typed: strict
module CommentsHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  # Any model with comments (Debate, Proposal, Budget::Investment, Legislation::Question...)
  sig { params(commentable: T.untyped).returns(String) }
  def leave_comment_text(commentable)
    if commentable.class == Legislation::Question
      t("legislation.questions.comments.form.leave_comment")
    else
      t("comments.form.leave_comment")
    end
  end

  sig { params(parent_id: T.nilable(T.any(String, Integer)), commentable: T.untyped).returns(String) }
  def comment_button_text(parent_id, commentable)
    if commentable.class == Legislation::Question
      if parent_id.present?
        t("comments_helper.reply_button")
      else
        t("legislation.questions.comments.comment_button")
      end
    else
      if parent_id.present?
        t("comments_helper.reply_button")
      else
        t("comments_helper.comment_button")
      end
    end
  end

  sig { params(parent_id: T.nilable(T.any(String, Integer)), commentable: T.untyped).returns(String) }
  def parent_or_commentable_dom_id(parent_id, commentable)
    parent_id.blank? ? dom_id(commentable) : "comment_#{parent_id}"
  end

  sig { params(comment: Comment).returns(String) }
  def commentable_path(comment)
    polymorphic_path(comment.commentable)
  end

  sig { params(commentable: T.untyped, current_user: User).returns(T.nilable(T::Boolean)) }
  def require_verified_resident_for_commentable?(commentable, current_user)
    return false if current_user.administrator? || current_user.moderator?

    commentable.respond_to?(:comments_for_verified_residents_only?) &&
      commentable.comments_for_verified_residents_only? &&
      !current_user.residence_verified?
  end

  sig { params(commentable: T.untyped).returns(T::Boolean) }
  def comments_closed_for_commentable?(commentable)
    commentable.respond_to?(:comments_closed?) && commentable.comments_closed?
  end
end
