# typed: true
class Admin::BudgetGroupsController < Admin::BaseController
  include Admin::BudgetGroupsActions

  sig { void }
  def new
    @group = @budget.groups.new
  end

  private

    sig { override.returns(String) }

    def groups_index
      admin_budget_path(@budget)
    end

    sig { override.returns(Symbol) }

    def new_action
      :new
    end
end
