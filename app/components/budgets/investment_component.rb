# typed: strict
class Budgets::InvestmentComponent < ApplicationComponent
  delegate :locale_and_user_status, :namespaced_budget_investment_path, :image_path_for, to: :helpers

  sig { returns(Budget::Investment) }
  attr_reader :investment

  sig { params(investment: Budget::Investment).void }
  def initialize(investment)
    @investment = investment
  end
end
