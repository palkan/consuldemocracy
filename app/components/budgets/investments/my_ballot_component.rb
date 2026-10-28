# typed: strict
class Budgets::Investments::MyBallotComponent < ApplicationComponent
  sig { returns(Budget::Ballot) }
  attr_reader :ballot

  sig { returns(T.nilable(Budget::Heading)) }
  attr_reader :heading, :assigned_heading

  sig { returns(T.nilable(T::Array[T.any(Integer, String)])) }
  attr_reader :investment_ids

  delegate :heading_link, to: :helpers

  sig do
    params(
      ballot: Budget::Ballot,
      heading: T.nilable(Budget::Heading),
      investment_ids: T.nilable(T::Array[T.any(Integer, String)]),
      assigned_heading: T.nilable(Budget::Heading)
    ).void
  end
  def initialize(ballot:, heading:, investment_ids:, assigned_heading: nil)
    @ballot = ballot
    @heading = heading
    @investment_ids = investment_ids
    @assigned_heading = assigned_heading
  end

  sig { returns(T.nilable(T::Boolean)) }
  def render?
    heading && can?(:show, ballot)
  end

  private

    sig { returns(Budget) }
    def budget
      T.must(ballot.budget)
    end

    sig { returns(Budget::Investment::PrivateAssociationRelation) }
    def investments
      ballot.investments.by_heading(T.must(heading).id).sort_by_ballot_lines
    end
end
