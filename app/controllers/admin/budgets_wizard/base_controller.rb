# typed: true
class Admin::BudgetsWizard::BaseController < Admin::BaseController
  helper_method :budget_mode, :single_heading?, :url_params

  private

    sig { returns(T.nilable(String)) }

    def budget_mode
      params[:mode]
    end

    sig { returns(T::Boolean) }

    def single_heading?
      budget_mode == "single"
    end

    sig { returns(T::Hash[Symbol, T.nilable(String)]) }

    def url_params
      budget_mode.present? ? { mode: budget_mode } : {}
    end
end
