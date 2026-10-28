# typed: true
module Budgets
  module Investments
    class VotesController < ApplicationController
      include FeatureFlags

      feature_flag :remove_investments_supports, only: :destroy

      load_and_authorize_resource :budget
      load_and_authorize_resource :investment, through: :budget, class: "Budget::Investment"
      load_and_authorize_resource through: :investment, through_association: :votes_for, only: :destroy

      sig { void }
      def create
        @investment.register_selection(current_user)

        respond_to do |format|
          format.html do
            redirect_to budget_investments_path(heading_id: @investment.heading.id),
                        notice: t("flash.actions.create.support")
          end

          format.js { render :show }
        end
      end

      sig { void }
      def destroy
        @investment.unliked_by(current_user)

        respond_to do |format|
          format.js { render :show }
        end
      end
    end
  end
end
