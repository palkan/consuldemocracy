# typed: true
module Budgets
  class GroupsController < ApplicationController
    include FeatureFlags

    feature_flag :budgets

    before_action :load_budget
    before_action :load_group, only: [:show]
    authorize_resource :budget
    authorize_resource :group, class: "Budget::Group"

    sig { void }
    def show
    end

    sig { void }
    def index
    end

    private

      sig { void }
      def load_budget
        @budget = Budget.find_by_slug_or_id! params[:budget_id]
      end

      sig { void }
      def load_group
        @group = @budget.groups.find_by_slug_or_id! params[:id]
      end
  end
end
