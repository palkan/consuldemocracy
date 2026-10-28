# typed: true
class Admin::HiddenBudgetInvestmentsController < Admin::BaseController
  include FeatureFlags
  include Admin::HiddenContent

  feature_flag :budgets

  before_action :load_investment, only: [:confirm_hide, :restore]

  sig { void }
  def index
    @investments = hidden_content(Budget::Investment.all)
  end

  sig { void }
  def confirm_hide
    @investment.confirm_hide
    redirect_with_query_params_to(action: :index)
  end

  sig { void }
  def restore
    @investment.restore(recursive: true)
    @investment.ignore_flag
    Activity.log(current_user, :restore, @investment)
    redirect_with_query_params_to(action: :index)
  end

  private

    sig { void }
    def load_investment
      @investment = Budget::Investment.with_hidden.find(params[:id])
    end
end
