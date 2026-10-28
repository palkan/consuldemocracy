# typed: strict
class Admin::Budgets::CalculateWinnersButtonComponent < ApplicationComponent
  sig { returns(Budget) }
  attr_reader :budget

  sig { returns(T::Boolean) }
  attr_reader :from_investments

  sig { params(budget: Budget, from_investments: T::Boolean).void }
  def initialize(budget, from_investments: false)
    @budget = budget
    @from_investments = from_investments
  end

  private

    sig { returns(String) }
    def text
      if budget.investments.winners.empty?
        t("admin.budgets.winners.calculate")
      else
        t("admin.budgets.winners.recalculate")
      end
    end

    sig { returns(T.nilable(String)) }
    def html_class
      "button hollow float-right clear" if from_investments
    end
end
