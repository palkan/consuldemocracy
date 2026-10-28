# typed: strict
module BudgetHeadingsHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params(budget: Budget).returns(T::Array[[T.nilable(String), Integer]]) }
  def budget_heading_select_options(budget)
    budget.headings.sort_by_name.map do |heading|
      [heading.name_scoped_by_group, heading.id]
    end
  end

  sig do
    params(assigned_heading: T.nilable(Budget::Heading), budget: T.nilable(Budget))
      .returns(T.nilable(ActiveSupport::SafeBuffer))
  end
  def heading_link(assigned_heading = nil, budget = nil)
    return nil unless assigned_heading && budget

    heading_path = budget_investments_path(budget, heading_id: assigned_heading.id)
    link_to(assigned_heading.name, heading_path)
  end
end
