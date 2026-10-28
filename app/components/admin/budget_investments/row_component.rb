# typed: strict
class Admin::BudgetInvestments::RowComponent < ApplicationComponent
  sig { returns(Budget::Investment) }
  attr_reader :investment

  sig { params(investment: Budget::Investment).void }
  def initialize(investment)
    @investment = investment
  end

  private

    sig { returns(Budget) }
    def budget
      T.must(investment.budget)
    end

    sig { returns(String) }
    def investment_path
      admin_budget_budget_investment_path(budget_id: budget.id,
                                          id: investment.id,
                                          params: Budget::Investment.filter_params(params).to_h)
    end

    sig { returns(String) }
    def administrator_info
      administrator = investment.administrator

      if administrator.present?
        tag.span(administrator.description_or_name,
                 title: t("admin.budget_investments.index.assigned_admin"))
      else
        t("admin.budget_investments.index.no_admin_assigned")
      end
    end

    sig { returns(String) }
    def valuators_info
      valuators = [investment.assigned_valuation_groups, investment.assigned_valuators].compact

      if valuators.present?
        valuators.join(", ")
      else
        t("admin.budget_investments.index.no_valuators_assigned")
      end
    end
end
