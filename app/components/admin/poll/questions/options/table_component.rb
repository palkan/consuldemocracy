# typed: strict
class Admin::Poll::Questions::Options::TableComponent < ApplicationComponent
  sig { returns(::Poll::Question) }
  attr_reader :question

  delegate :wysiwyg, to: :helpers

  sig { params(question: ::Poll::Question).void }
  def initialize(question)
    @question = question
  end
end
