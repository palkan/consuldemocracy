# typed: true
class Admin::BudgetHeadingsController < Admin::BaseController
  include Admin::BudgetHeadingsActions

  sig { void }
  def new
    @heading = @group.headings.new
  end

  private

    sig { override.returns(String) }

    def headings_index
      admin_budget_path(@budget)
    end

    sig { override.returns(Symbol) }

    def new_action
      :new
    end
end
