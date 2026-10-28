# typed: strict
class ReplyEmail
  extend T::Sig

  sig { returns(Comment) }
  attr_reader :reply

  sig { params(reply: Comment).void }
  def initialize(reply)
    @reply = reply
  end

  sig { returns(T.nilable(ApplicationRecord)) }
  def commentable
    reply.commentable
  end

  sig { returns(T.nilable(User)) }
  def recipient
    reply.parent.author
  end

  sig { returns(T.nilable(String)) }
  def to
    T.must(recipient).email
  end

  sig { returns(String) }
  def subject
    I18n.t("mailers.reply.subject")
  end

  sig { returns(T::Boolean) }
  def can_be_sent?
    commentable.present? && recipient.present?
  end
end
