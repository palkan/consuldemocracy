# typed: strict
class Admin::BudgetInvestments::ToggleSelectionComponent < ApplicationComponent
  sig { returns(Budget::Investment) }
  attr_reader :investment

  delegate :selected?, to: :investment

  sig { params(investment: Budget::Investment).void }
  def initialize(investment)
    @investment = investment
  end

  private

    sig { returns(String) }
    def selected_text
      t("admin.budget_investments.index.selected")
    end

    sig { returns(Symbol) }
    def action
      if selected?
        :deselect
      else
        :select
      end
    end

    sig { returns(String) }
    def path
      url_for({
        controller: "admin/budget_investments",
        action: action,
        budget_id: investment.budget,
        id: investment,
        filter: params[:filter],
        sort_by: params[:sort_by],
        min_total_supports: params[:min_total_supports],
        max_total_supports: params[:max_total_supports],
        advanced_filters: params[:advanced_filters],
        page: params[:page]
      })
    end

    sig { returns(T::Hash[Symbol, String]) }
    def options
      {
        "aria-label": label,
        form_class: "toggle-selection",
        path: path
      }
    end

    sig { returns(String) }
    def label
      t("admin.actions.label", action: t("admin.actions.select"), name: investment.title)
    end
end
