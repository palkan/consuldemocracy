# typed: strict
class Users::BudgetInvestmentTableActionsComponent < ApplicationComponent
  sig { returns(Budget::Investment) }
  attr_reader :investment

  sig { params(investment: Budget::Investment).void }
  def initialize(investment)
    @investment = investment
  end

  private

    sig { returns(ActiveSupport::SafeBuffer) }
    def edit_link
      link_to t("shared.edit"),
              edit_budget_investment_path(investment.budget, investment),
              "aria-label": action_label(t("shared.edit")),
              class: "button hollow"
    end

    sig { returns(ActiveSupport::SafeBuffer) }
    def destroy_button
      button_to t("shared.delete"),
                budget_investment_path(investment.budget, investment),
                method: :delete,
                "aria-label": action_label(t("shared.delete")),
                class: "button hollow alert",
                data: { confirm: t("users.show.delete_alert") }
    end

    sig { params(action_text: String).returns(String) }
    def action_label(action_text)
      t("shared.actions.label", action: action_text, name: investment.title)
    end
end
