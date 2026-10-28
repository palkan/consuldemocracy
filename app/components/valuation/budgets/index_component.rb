# typed: strict
class Valuation::Budgets::IndexComponent < ApplicationComponent
  sig { returns(Budget::PrivateRelation) }
  attr_reader :budgets

  sig { params(budgets: Budget::PrivateRelation).void }
  def initialize(budgets)
    @budgets = budgets
  end
end
