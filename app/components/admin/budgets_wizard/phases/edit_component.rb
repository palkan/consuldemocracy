# typed: strict
class Admin::BudgetsWizard::Phases::EditComponent < ApplicationComponent
  include Header

  sig { returns(Budget::Phase) }
  attr_reader :phase

  sig { params(phase: Budget::Phase).void }
  def initialize(phase)
    @phase = phase
  end

  sig { returns(Budget) }
  def budget
    T.must(phase.budget)
  end

  sig { override.returns(String) }
  def title
    "#{t("admin.budget_phases.edit.title")} - #{phase.name}"
  end

  private

    sig { returns(String) }
    def form_path
      admin_budgets_wizard_budget_budget_phases_path(budget)
    end
end
