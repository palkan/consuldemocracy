# typed: strict
class Admin::BudgetsWizard::Headings::EditComponent < ApplicationComponent
  include Header

  sig { returns(Budget::Heading) }
  attr_reader :heading

  sig { params(heading: Budget::Heading).void }
  def initialize(heading)
    @heading = heading
  end

  sig { returns(Budget) }
  def budget
    heading.budget
  end

  sig { returns(T.nilable(Budget::Group)) }
  def group
    heading.group
  end

  sig { override.returns(T.nilable(String)) }
  def title
    heading.name
  end

  private

    sig { returns(String) }
    def form_path
      admin_budgets_wizard_budget_group_heading_path(budget, group, heading)
    end
end
