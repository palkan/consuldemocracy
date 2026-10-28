# typed: true
class BudgetsController < ApplicationController
  include FeatureFlags

  feature_flag :budgets

  before_action :load_budget, only: :show
  before_action :load_current_budget, only: :index
  load_and_authorize_resource

  respond_to :html, :js

  sig { void }
  def show
    raise ActionController::RoutingError, "Not Found" unless helpers.budget_published?(@budget)
  end

  sig { void }
  def index
    @finished_budgets = @budgets.finished.order(created_at: :desc)
  end

  private

    sig { void }
    def load_budget
      @budget = Budget.find_by_slug_or_id! params[:id]
    end

    sig { void }
    def load_current_budget
      @budget = current_budget
    end
end
