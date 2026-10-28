# typed: strict
class Admin::Budgets::TableActionsComponent < ApplicationComponent
  sig { returns(Budget) }
  attr_reader :budget

  sig { params(budget: Budget).void }
  def initialize(budget)
    @budget = budget
  end

  private

    sig { returns(Admin::TableActionsComponent) }
    def actions_component
      Admin::TableActionsComponent.new(
        budget,
        edit_path: admin_budget_path(budget),
        actions: [:edit]
      )
    end
end
