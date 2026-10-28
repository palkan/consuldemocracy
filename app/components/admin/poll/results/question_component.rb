# typed: strict
class Admin::Poll::Results::QuestionComponent < ApplicationComponent
  PartialResults = T.type_alias do
    T.any(
      ::Poll::PartialResult::PrivateRelation,
      ::Poll::PartialResult::PrivateAssociationRelation,
      ::Poll::PartialResult::PrivateCollectionProxy
    )
  end

  sig { returns(::Poll::Question) }
  attr_reader :question

  sig { returns(PartialResults) }
  attr_reader :partial_results

  sig { params(question: ::Poll::Question, partial_results: PartialResults).void }
  def initialize(question, partial_results)
    @question = question
    @partial_results = partial_results
  end

  sig { params(option: ::Poll::Question::Option).returns(Numeric) }
  def votes_for(option)
    partial_results.where(option: option).sum(:amount)
  end
end
