# typed: strict
class Officing::Results::IndexComponent < ApplicationComponent
  sig { returns(Poll) }
  attr_reader :poll

  sig { returns(T.nilable(Poll::PartialResult::PrivateRelation)) }
  attr_reader :partial_results

  sig { returns(Poll::BoothAssignment) }
  attr_reader :booth_assignment

  sig { returns(T.nilable(Poll::Recount::PrivateRelation)) }
  attr_reader :recounts

  sig do
    params(
      poll: Poll,
      partial_results: T.nilable(Poll::PartialResult::PrivateRelation),
      booth_assignment: Poll::BoothAssignment,
      recounts: T.nilable(Poll::Recount::PrivateRelation)
    ).void
  end
  def initialize(poll, partial_results, booth_assignment, recounts)
    @poll = poll
    @partial_results = partial_results
    @booth_assignment = booth_assignment
    @recounts = recounts
  end
end
