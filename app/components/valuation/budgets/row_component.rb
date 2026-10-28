# typed: strict
class Valuation::Budgets::RowComponent < ApplicationComponent
  sig { returns(Budget) }
  attr_reader :budget

  with_collection_parameter :budget

  sig { params(budget: Budget).void }
  def initialize(budget:)
    @budget = budget
  end

  sig { returns(T.any(Budget::Investment::PrivateRelation, Budget::Investment::PrivateAssociationRelation)) }
  def investments
    return Budget::Investment.none unless budget.valuating_or_later?

    budget.investments.visible_to_valuator(T.must(current_user).valuator)
  end

  sig { returns(Integer) }
  def valuation_open_investments_count
    return 0 unless budget.valuating?

    investments.valuation_open.count
  end
end
