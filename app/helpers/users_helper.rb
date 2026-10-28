# typed: strict
module UsersHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }
  requires_ancestor { AdminHelper }

  sig { params(document_type: T.nilable(String)).returns(T.nilable(String)) }
  def humanize_document_type(document_type)
    case document_type
    when "1"
      t "verification.residence.new.document_type.spanish_id"
    when "2"
      t "verification.residence.new.document_type.passport"
    when "3"
      t "verification.residence.new.document_type.residence_card"
    end
  end

  sig { params(comment: Comment).returns(T.any(String, ActiveSupport::SafeBuffer)) }
  def comment_commentable_title(comment)
    commentable = comment.commentable
    if commentable.nil?
      deleted_commentable_text(comment)
    elsif commentable.hidden?
      tag.del(commentable.title) + " " +
        tag.span("(#{deleted_commentable_text(comment)})", class: "small")
    else
      link_to(commentable.title, comment)
    end
  end

  sig { params(comment: Comment).returns(String) }
  def deleted_commentable_text(comment)
    case comment.commentable_type
    when "Proposal"
      t("users.show.deleted_proposal")
    when "Debate"
      t("users.show.deleted_debate")
    when "Budget::Investment"
      t("users.show.deleted_budget_investment")
    else
      t("users.show.deleted")
    end
  end

  sig { params(user: T.nilable(User)).returns(T.nilable(T::Boolean)) }
  def show_admin_menu?(user)
    unless namespace == "officing"
      user&.administrator? || user&.moderator? || user&.valuator? ||
        (user&.manager? && namespace != "management") || user&.poll_officer? || user&.sdg_manager?
    end
  end

  sig { params(user: User).returns(String) }
  def interests_title_text(user)
    if current_user == user
      t("account.show.public_interests_my_title_list")
    else
      t("account.show.public_interests_user_title_list")
    end
  end
end
