# typed: strict
class Admin::Poll::Questions::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  sig { returns(::Poll::Question) }
  attr_reader :question

  sig { returns(String) }
  attr_reader :url

  sig { params(question: ::Poll::Question, url: String).void }
  def initialize(question, url:)
    @question = question
    @url = url
  end

  private

    sig { returns(T::Array[[T.untyped, Integer]]) }
    def select_options
      Poll.all.select { |poll| can?(:create, Poll::Question.new(poll: poll)) }.map do |poll|
        [poll.name, poll.id]
      end
    end
end
