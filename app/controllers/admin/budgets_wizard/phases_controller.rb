# typed: true
class Admin::BudgetsWizard::PhasesController < Admin::BudgetsWizard::BaseController
  include Admin::BudgetPhasesActions

  sig { void }
  def index
  end

  private

    sig { override.returns(String) }

    def phases_index
      admin_budgets_wizard_budget_budget_phases_path(@phase.budget, url_params)
    end
end
