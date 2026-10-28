# typed: strict
class Polls::Results::QuestionComponent < ApplicationComponent
  sig { returns(Poll::Question) }
  attr_reader :question

  delegate :number_to_stats_percentage, to: :helpers

  sig { params(question: Poll::Question).void }
  def initialize(question)
    @question = question
  end

  sig { params(option: Poll::Question::Option).returns(T.nilable(String)) }
  def option_styles(option)
    "win" if most_voted_option?(option)
  end

  sig { params(option: Poll::Question::Option).returns(T::Boolean) }
  def most_voted_option?(option)
    option.id == question.most_voted_option_id
  end

  sig { params(number: Numeric, percentage: Numeric).returns(ActiveSupport::SafeBuffer) }
  def number_with_percentage(number, percentage)
    safe_join([number, "(#{number_to_stats_percentage(percentage)})"], " ")
  end
end
