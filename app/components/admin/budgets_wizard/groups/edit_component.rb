# typed: strict
class Admin::BudgetsWizard::Groups::EditComponent < ApplicationComponent
  include Header

  sig { returns(Budget::Group) }
  attr_reader :group

  sig { params(group: Budget::Group).void }
  def initialize(group)
    @group = group
  end

  sig { returns(Budget) }
  def budget
    T.must(group.budget)
  end

  sig { override.returns(T.nilable(String)) }
  def title
    budget.name
  end

  private

    sig { returns(String) }
    def form_path
      admin_budgets_wizard_budget_group_path(budget, group)
    end
end
