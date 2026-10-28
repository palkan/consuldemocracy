# typed: strict
class Admin::BudgetsWizard::Headings::CreationStepComponent < ApplicationComponent
  sig { returns(Budget::Heading) }
  attr_reader :heading

  sig { params(heading: Budget::Heading).void }
  def initialize(heading)
    @heading = heading
  end

  private

    sig { returns(Budget) }
    def budget
      heading.budget
    end

    sig { returns(String) }
    def form_path
      group = T.must(heading.group)

      if heading.persisted?
        admin_budgets_wizard_budget_group_heading_path(group.budget, group, heading)
      else
        admin_budgets_wizard_budget_group_headings_path(group.budget, group)
      end
    end

    sig { returns(T.nilable(String)) }
    def next_step_path
      admin_budgets_wizard_budget_budget_phases_path(budget) if next_step_enabled?
    end

    sig { returns(T::Boolean) }
    def next_step_enabled?
      budget.headings.any?
    end
end
