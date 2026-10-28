# typed: strict
class Admin::BudgetsWizard::Budgets::NewComponent < ApplicationComponent
  include Header

  sig { returns(Budget) }
  attr_reader :budget

  delegate :single_heading?, to: :helpers

  sig { params(budget: Budget).void }
  def initialize(budget)
    @budget = budget
  end

  sig { override.returns(String) }
  def title
    if single_heading?
      t("admin.budgets.new.title_single")
    else
      t("admin.budgets.new.title_multiple")
    end
  end
end
