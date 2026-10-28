# typed: strict
class Admin::BudgetsWizard::Groups::IndexComponent < Admin::BudgetsWizard::BaseComponent
  include Header

  Groups = T.type_alias do
    T.any(
      Budget::Group::PrivateRelation,
      Budget::Group::PrivateAssociationRelation,
      Budget::Group::PrivateCollectionProxy
    )
  end

  sig { returns(Groups) }
  attr_reader :groups

  sig { returns(Budget::Group) }
  attr_reader :new_group

  sig do
    params(
      groups: Groups,
      new_group: Budget::Group
    ).void
  end
  def initialize(groups, new_group)
    @groups = groups
    @new_group = new_group
  end

  sig { returns(Budget) }
  def budget
    T.must(@new_group.budget)
  end

  sig { override.returns(T.nilable(String)) }
  def title
    budget.name
  end
end
