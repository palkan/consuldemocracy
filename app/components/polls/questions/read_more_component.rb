# typed: strict
class Polls::Questions::ReadMoreComponent < ApplicationComponent
  with_collection_parameter :question

  sig { returns(Poll::Question) }
  attr_reader :question

  delegate :wysiwyg, to: :helpers

  sig { params(question: Poll::Question).void }
  def initialize(question:)
    @question = question
  end

  sig { returns(T::Boolean) }
  def render?
    question.options_with_read_more?
  end
end
