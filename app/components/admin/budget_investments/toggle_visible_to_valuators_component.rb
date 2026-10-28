# typed: strict
class Admin::BudgetInvestments::ToggleVisibleToValuatorsComponent < ApplicationComponent
  sig { returns(Budget::Investment) }
  attr_reader :investment

  delegate :visible_to_valuators?, to: :investment

  sig { params(investment: Budget::Investment).void }
  def initialize(investment)
    @investment = investment
  end

  private

    sig { returns(Symbol) }
    def action
      if visible_to_valuators?
        :hide_from_valuators
      else
        :show_to_valuators
      end
    end

    sig { returns(String) }
    def text
      if visible_to_valuators?
        t("shared.yes")
      else
        t("shared.no")
      end
    end

    sig { returns(T::Hash[Symbol, String]) }
    def options
      {
        "aria-label": label,
        form_class: "visible-to-valuators"
      }
    end

    sig { returns(String) }
    def label
      t("admin.actions.show_to_valuators", name: investment.title)
    end
end
