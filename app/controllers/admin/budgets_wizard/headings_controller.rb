# typed: true
class Admin::BudgetsWizard::HeadingsController < Admin::BudgetsWizard::BaseController
  include Admin::BudgetHeadingsActions

  before_action :load_headings, only: [:index, :create]

  sig { void }
  def index
    if single_heading?
      @heading = @group.headings.first_or_initialize
    else
      @heading = @group.headings.new
    end
  end

  private

    sig { override.returns(String) }

    def headings_index
      if single_heading?
        admin_budgets_wizard_budget_budget_phases_path(@budget, url_params)
      else
        admin_budgets_wizard_budget_group_headings_path(@budget, @group, url_params)
      end
    end

    sig { void }
    def load_headings
      @headings = @group.headings.order(:id)
    end

    sig { override.returns(Symbol) }

    def new_action
      :index
    end
end
