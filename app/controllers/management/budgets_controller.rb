# typed: true
class Management::BudgetsController < Management::BaseController
  include FeatureFlags
  include HasFilters

  feature_flag :budgets

  before_action :only_verified_users, except: :print_investments

  sig { void }
  def create_investments
    @budgets = Budget.accepting.order(created_at: :desc).page(params[:page])

    if T.must(current_manager).administrator?
      @budgets += Budget.reviewing.order(created_at: :desc) +
                  Budget.selecting.order(created_at: :desc)
    end
  end

  sig { void }
  def support_investments
    @budgets = Budget.selecting.order(created_at: :desc).page(params[:page])
  end

  sig { void }
  def print_investments
    @budgets = Budget.published.order(created_at: :desc).page(params[:page])
  end

  private

    sig { void }
    def only_verified_users
      check_verified_user t("management.budget_investments.alert.unverified_user")
    end
end
