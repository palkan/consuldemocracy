# typed: strict
class EvaluationCommentEmail
  extend T::Sig

  sig { returns(Comment) }
  attr_reader :comment

  sig { params(comment: Comment).void }
  def initialize(comment)
    @comment = comment
    @to = T.let(nil, T.nilable(T::Array[T.any(Valuator, Administrator)]))
  end

  sig { returns(T.nilable(Budget::Investment)) }
  def commentable
    comment.commentable
  end

  sig { returns(T::Array[T.any(Valuator, Administrator)]) }
  def to
    @to ||= related_users
  end

  sig { returns(String) }
  def subject
    I18n.t("mailers.evaluation_comment.subject")
  end

  sig { returns(T::Boolean) }
  def can_be_sent?
    commentable.present? && to.any?
  end

  private

    sig { returns(T::Array[T.any(Valuator, Administrator)]) }
    def related_users
      return [] if comment.commentable.nil?

      comment.commentable
             .admin_and_valuator_users_associated
             .reject { |associated_user| associated_user.user == comment.author }
    end
end
