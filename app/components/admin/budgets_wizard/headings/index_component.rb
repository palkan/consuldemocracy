# typed: strict
class Admin::BudgetsWizard::Headings::IndexComponent < Admin::BudgetsWizard::BaseComponent
  include Header

  sig { returns(T.any(Budget::Heading::PrivateAssociationRelation, Budget::Heading::PrivateCollectionProxy)) }
  attr_reader :headings

  sig { returns(Budget::Heading) }
  attr_reader :new_heading

  sig do
    params(
      headings: T.any(Budget::Heading::PrivateAssociationRelation, Budget::Heading::PrivateCollectionProxy),
      new_heading: Budget::Heading
    ).void
  end
  def initialize(headings, new_heading)
    @headings = headings
    @new_heading = new_heading
  end

  sig { returns(Budget) }
  def budget
    T.must(group.budget)
  end

  sig { returns(Budget::Group) }
  def group
    T.must(new_heading.group)
  end

  sig { override.returns(String) }
  def title
    t("admin.budget_headings.index.title", budget: budget.name, group: group.name)
  end

  sig { returns(String) }
  def back_link_text
    if single_heading?
      t("admin.budgets_wizard.headings.single.back")
    else
      t("admin.budget_headings.index.back")
    end
  end
end
