# typed: strict
class Admin::Poll::Questions::TableActionsComponent < ApplicationComponent
  sig { returns(::Poll::Question) }
  attr_reader :question

  sig { params(question: ::Poll::Question).void }
  def initialize(question)
    @question = question
  end
end
