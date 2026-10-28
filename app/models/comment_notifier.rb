# typed: strict
class CommentNotifier
  extend T::Sig

  sig { params(args: T::Hash[Symbol, Comment]).void }
  def initialize(args = {})
    @comment = T.let(args.fetch(:comment), Comment)
    @author  = T.let(@comment.author, T.nilable(User))
  end

  sig { void }
  def process
    send_comment_email
    send_reply_email
  end

  private

    sig { void }
    def send_comment_email
      if !@comment.commentable.is_a?(Legislation::Annotation) && email_on_comment?
        Mailer.comment(@comment).deliver_later
      end
    end

    sig { void }
    def send_reply_email
      Mailer.reply(@comment).deliver_later if email_on_comment_reply?
    end

    sig { returns(T::Boolean) }
    def email_on_comment?
      commentable_author = @comment.commentable.author
      commentable_author != @author && commentable_author.email_on_comment?
    end

    sig { returns(T::Boolean) }
    def email_on_comment_reply?
      return false unless @comment.reply?

      parent_author = @comment.parent.author
      parent_author != @author && parent_author.email_on_comment_reply?
    end
end
