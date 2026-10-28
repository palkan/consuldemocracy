# typed: strict
class Admin::BudgetsWizard::Budgets::EditComponent < ApplicationComponent
  include Header

  sig { returns(Budget) }
  attr_reader :budget

  sig { params(budget: Budget).void }
  def initialize(budget)
    @budget = budget
  end

  sig { override.returns(String) }
  def title
    t("admin.budgets.edit.title")
  end
end
