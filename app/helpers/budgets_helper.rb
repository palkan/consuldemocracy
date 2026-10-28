# typed: true
module BudgetsHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }
  requires_ancestor { AdminHelper }

  sig { params(investment: Budget::Investment, options: T::Hash[Symbol, T.untyped]).returns(String) }
  def namespaced_budget_investment_path(investment, options = {})
    case namespace
    when "management"
      management_budget_investment_path(investment.budget, investment, options)
    else
      budget_investment_path(investment.budget, investment, options)
    end
  end

  sig { params(heading: Budget::Heading).returns(String) }
  def css_for_ballot_heading(heading)
    current_ballot&.has_lines_in_heading?(heading) ? "is-active" : ""
  end

  sig { returns(T.nilable(Budget::Ballot)) }
  def current_ballot
    Budget::Ballot.find_by(user: current_user, budget: @budget)
  end

  sig { returns(T::Boolean) }
  def unfeasible_or_unselected_filter?
    ["unselected", "unfeasible"].include?(@current_filter)
  end

  sig { params(budget: Budget).returns(T.nilable(T::Boolean)) }
  def budget_published?(budget)
    budget.published? || current_user&.administrator?
  end

  sig { params(budget: Budget).returns(T::Array[{ text: String, url: String, active: T::Boolean }]) }
  def budget_subnav_items_for(budget)
    {
      results: t("budgets.results.link"),
      stats: t("stats.budgets.link"),
      executions: t("budgets.executions.link")
    }.select { |section, _| can?(:"read_#{section}", budget) }.map do |section, text|
      {
        text: text,
        url: send("budget_#{section}_path", budget),
        active: controller_name == section.to_s
      }
    end
  end
end
