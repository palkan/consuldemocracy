# typed: strict
class Admin::BudgetPhases::PhasesComponent < ApplicationComponent
  sig { returns(Budget) }
  attr_reader :budget

  sig { params(budget: Budget).void }
  def initialize(budget)
    @budget = budget
  end

  private

    sig { returns(Budget::Phase::PrivateAssociationRelation) }
    def phases
      budget.phases.order(:id)
    end

    sig { params(phase: Budget::Phase).returns(ActiveSupport::SafeBuffer) }
    def dates(phase)
      render Admin::DurationComponent.new(phase)
    end

    sig { params(phase: Budget::Phase).returns(ActiveSupport::SafeBuffer) }
    def enabled_cell(phase)
      render Admin::BudgetPhases::ToggleEnabledComponent.new(phase)
    end

    sig { params(phase: Budget::Phase).returns(T.nilable(String)) }
    def edit_path(phase)
      if helpers.respond_to?(:single_heading?) && helpers.single_heading?
        edit_admin_budgets_wizard_budget_budget_phase_path(budget, phase, helpers.url_params)
      end
    end
end
