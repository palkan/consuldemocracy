# typed: strict
class Admin::BudgetsWizard::Headings::GroupSwitcherComponent < ApplicationComponent
  sig { returns(Budget::Group) }
  attr_reader :group

  delegate :link_list, to: :helpers

  sig { params(group: Budget::Group).void }
  def initialize(group)
    @group = group
    @other_groups = T.let(nil, T.nilable(T::Array[Budget::Group]))
  end

  sig { returns(T::Boolean) }
  def render?
    other_groups.any?
  end

  private

    sig { returns(Budget) }
    def budget
      T.must(group.budget)
    end

    sig { returns(T::Array[Budget::Group]) }
    def other_groups
      @other_groups ||= budget.groups.sort_by_name - [group]
    end

    sig { params(group: Budget::Group).returns(String) }
    def headings_path(group)
      admin_budgets_wizard_budget_group_headings_path(budget, group)
    end

    sig { returns(ActiveSupport::SafeBuffer) }
    def currently_showing_text
      sanitize(t("admin.budget_headings.group_switcher.currently_showing", group: group.name))
    end

    sig { params(group: Budget::Group).returns(ActiveSupport::SafeBuffer) }
    def link_to_group(group)
      link_to(link_to_group_text(group), headings_path(group))
    end

    sig { params(group: Budget::Group).returns(ActiveSupport::SafeBuffer) }
    def link_to_group_text(group)
      sanitize(t("admin.budget_headings.group_switcher.the_other_group", group: tag.strong(group.name)))
    end
end
