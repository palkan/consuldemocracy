# typed: true
class Admin::BudgetPhasesController < Admin::BaseController
  include Admin::BudgetPhasesActions

  private

    sig { override.returns(String) }

    def phases_index
      admin_budget_path(@phase.budget)
    end
end
