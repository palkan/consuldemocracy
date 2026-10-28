# typed: strict
class Management::Budgets::PrintInvestments::TableComponent < ApplicationComponent
  sig { returns(Budget::PrivateRelation) }
  attr_reader :budgets

  sig { params(budgets: Budget::PrivateRelation).void }
  def initialize(budgets)
    @budgets = budgets
  end
end
