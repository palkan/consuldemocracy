# typed: strict
class Budgets::InvestmentsListComponent < ApplicationComponent
  sig { returns(Budget) }
  attr_reader :budget

  sig { params(budget: Budget).void }
  def initialize(budget)
    @budget = budget
  end

  sig do
    params(limit: Integer)
      .returns(T.any(T::Array[Budget::Investment], Budget::Investment::PrivateAssociationRelation))
  end
  def investments(limit: 9)
    case budget.phase
    when "accepting", "reviewing"
      budget.investments.sample(limit)
    when "selecting", "valuating", "publishing_prices"
      budget.investments.feasible.sample(limit)
    when "balloting", "reviewing_ballots"
      budget.investments.selected.sample(limit)
    else
      budget.investments.none
    end
  end

  sig { returns(String) }
  def see_all_path
    if budget.single_heading?
      budget_investments_path(budget)
    else
      budget_groups_path(budget)
    end
  end
end
