# typed: true
module Budgets
  class StatsController < ApplicationController
    include FeatureFlags

    feature_flag :budgets

    before_action :load_budget
    authorize_resource :budget

    sig { void }
    def show
      authorize! :read_stats, @budget
      @stats = Budget::Stats.new(@budget).tap(&:generate)
    end

    private

      sig { void }
      def load_budget
        @budget = Budget.find_by_slug_or_id! params[:budget_id]
      end
  end
end
