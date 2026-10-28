# typed: strict
class Admin::Budgets::LinksComponent < ApplicationComponent
  sig { returns(Budget) }
  attr_reader :budget

  sig { params(budget: Budget).void }
  def initialize(budget)
    @budget = budget
  end

  private

    sig { params(action_name: Symbol, "**": T.untyped).returns(ActiveSupport::SafeBuffer) }
    def action(action_name, **)
      render Admin::ActionComponent.new(action_name, budget, **)
    end

    sig { returns(String) }
    def results_text
      if Abilities::Everyone.new(User.new).can?(:read_results, budget)
        t("budgets.show.see_results")
      else
        t("admin.budgets.actions.preview_results")
      end
    end

    sig { returns(String) }
    def preview_text
      if budget.published?
        t("admin.shared.view")
      else
        t("admin.budgets.actions.preview")
      end
    end
end
