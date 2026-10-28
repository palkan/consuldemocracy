# typed: strict
class Admin::BudgetsWizard::Groups::CreationStepComponent < ApplicationComponent
  sig { returns(Budget::Group) }
  attr_reader :group

  sig { returns(T.nilable(Budget::Group)) }
  attr_reader :next_step_group

  sig { params(group: Budget::Group, next_step_group: T.nilable(Budget::Group)).void }
  def initialize(group, next_step_group)
    @group = group
    @next_step_group = next_step_group
  end

  private

    sig { returns(T.nilable(Budget)) }
    def budget
      group.budget
    end

    sig { returns(String) }
    def form_path
      if group.persisted?
        admin_budgets_wizard_budget_group_path(budget, group)
      else
        admin_budgets_wizard_budget_groups_path(budget)
      end
    end

    sig { returns(T.nilable(String)) }
    def next_step_path
      admin_budgets_wizard_budget_group_headings_path(budget, next_step_group) if next_step_enabled?
    end

    sig { returns(T::Boolean) }
    def next_step_enabled?
      next_step_group.present?
    end
end
