# typed: strict
class MachineLearning::CommentsSummaryComponent < ApplicationComponent
  sig { returns(T.untyped) }
  attr_reader :commentable

  sig { params(commentable: T.untyped).void }
  def initialize(commentable)
    @commentable = commentable
  end

  sig { returns(T::Boolean) }
  def render?
    MachineLearning.enabled? && Setting["machine_learning.comments_summary"].present? && body.present?
  end

  private

    sig { returns(T.nilable(String)) }
    def body
      commentable.summary_comment&.body
    end
end
