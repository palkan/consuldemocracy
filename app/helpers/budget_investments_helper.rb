# typed: strict
module BudgetInvestmentsHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }
  requires_ancestor { ImageablesHelper }

  sig { params(params: T::Array[String]).returns(String) }
  def budget_investments_advanced_filters(params)
    params.map { |af| t("admin.budget_investments.index.filters.#{af}") }.join(", ")
  end

  sig { params(direction: T.nilable(String), sort_by: T.any(String, Symbol)).returns(String) }
  def set_sorting_icon(direction, sort_by)
    if sort_by.to_s == params[:sort_by]
      if direction == "desc"
        "desc"
      else
        "asc"
      end
    else
      ""
    end
  end

  sig { params(current_direction: T.nilable(String)).returns(String) }
  def set_direction(current_direction)
    current_direction == "desc" ? "asc" : "desc"
  end

  sig { params(investment: Budget::Investment).returns(T::Boolean) }
  def show_author_actions?(investment)
    can?(:edit, investment) || can_destroy_image?(investment)
  end
end
