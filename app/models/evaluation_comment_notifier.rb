# typed: strict
class EvaluationCommentNotifier
  extend T::Sig

  sig { params(args: T::Hash[Symbol, Comment]).void }
  def initialize(args = {})
    @comment = T.let(args.fetch(:comment), Comment)
  end

  sig { void }
  def process
    send_evaluation_comment_email
  end

  private

    sig { void }
    def send_evaluation_comment_email
      EvaluationCommentEmail.new(@comment).to.each do |to|
        Mailer.evaluation_comment(@comment, to).deliver_later
      end
    end
end
