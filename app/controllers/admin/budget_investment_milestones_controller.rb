# typed: true
class Admin::BudgetInvestmentMilestonesController < Admin::MilestonesController
  private

    sig { returns(Budget::Investment) }

    def milestoneable
      Budget::Investment.find(params[:budget_investment_id])
    end
end
