# typed: strict
class Admin::BudgetsWizard::Phases::IndexComponent < Admin::BudgetsWizard::BaseComponent
  include Header

  sig { returns(Budget) }
  attr_reader :budget

  sig { params(budget: Budget).void }
  def initialize(budget)
    @budget = budget
  end

  sig { override.returns(String) }
  def title
    t("admin.budget_phases.index.title", budget: budget.name)
  end

  private

    sig { returns(String) }
    def back_link_path
      admin_budgets_wizard_budget_group_headings_path(budget, budget.groups.first, url_params)
    end

    sig { returns(String) }
    def back_link_text
      t("admin.budgets_wizard.phases.#{budget_mode}.back")
    end
end
