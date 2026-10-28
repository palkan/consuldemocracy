# typed: strict
class Admin::BudgetGroups::GroupsComponent < ApplicationComponent
  include Admin::Namespace

  Groups = T.type_alias do
    T.any(
      Budget::Group::PrivateRelation,
      Budget::Group::PrivateAssociationRelation,
      Budget::Group::PrivateCollectionProxy
    )
  end

  sig { returns(Groups) }
  attr_reader :groups

  sig { params(groups: Groups).void }
  def initialize(groups)
    @groups = groups
    @budget = T.let(nil, T.nilable(Budget))
  end

  private

    sig { returns(T.nilable(Budget)) }
    def budget
      @budget ||= T.must(groups.first).budget
    end

    sig { params(group: Budget::Group).returns(String) }
    def headings_path(group)
      send("#{namespace}_budget_group_headings_path", group.budget, group)
    end
end
