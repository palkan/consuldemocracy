# typed: true
class Admin::BudgetInvestmentProgressBarsController < Admin::ProgressBarsController
  private

    sig { returns(Budget::Investment) }

    def progressable
      Budget::Investment.find(params[:budget_investment_id])
    end
end
