# typed: strict
class Budgets::Ballot::BallotComponent < ApplicationComponent
  sig { returns(Budget::Ballot) }
  attr_reader :ballot

  sig { params(ballot: Budget::Ballot).void }
  def initialize(ballot)
    @ballot = ballot
  end

  sig { returns(Budget) }
  def budget
    T.must(ballot.budget)
  end

  private

    sig { returns(T::Array[Budget::Group]) }
    def ballot_groups
      ballot.groups.sort_by_name
    end

    sig { returns(T::Array[Budget::Group]) }
    def no_balloted_groups
      budget.groups.sort_by_name - ballot.groups.to_a
    end

    sig { params(group: Budget::Group).returns(String) }
    def group_path(group)
      if group.multiple_headings?
        budget_group_path(budget, group)
      else
        budget_investments_path(budget, heading_id: group.headings.first)
      end
    end

    sig { params(group: Budget::Group).returns(Budget::Investment::PrivateAssociationRelation) }
    def group_investments(group)
      ballot.investments.by_group(group.id).sort_by_ballot_lines
    end
end
