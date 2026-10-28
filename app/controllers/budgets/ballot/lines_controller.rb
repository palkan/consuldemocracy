# typed: true
module Budgets
  module Ballot
    class LinesController < ApplicationController
      before_action :authenticate_user!
      before_action :load_budget
      before_action :load_ballot
      before_action :load_categories
      before_action :load_investments

      authorize_resource :budget
      authorize_resource :ballot
      load_and_authorize_resource :line, through: :ballot,
                                         find_by: :investment_id,
                                         class: "Budget::Ballot::Line"

      sig { void }
      def create
        load_investment
        load_heading

        @ballot.add_investment(@investment)
      end

      sig { void }
      def destroy
        @investment = @line.investment
        load_heading

        @line.destroy!
        load_investments
      end

      private

        sig { returns(ActionController::Parameters) }
        def line_params
          params.permit(allowed_params)
        end

        sig { returns(T::Array[T.untyped]) }
        def allowed_params
          [:investment_id, :budget_id]
        end

        sig { void }
        def load_budget
          @budget = Budget.find_by_slug_or_id! params[:budget_id]
        end

        sig { void }
        def load_ballot
          @ballot = Budget::Ballot.where(user: current_user, budget: @budget).first_or_create!
        end

        sig { void }
        def load_investment
          @investment = Budget::Investment.find(params[:investment_id])
        end

        sig { void }
        def load_investments
          if params[:investments_ids].present?
            @investment_ids = params[:investments_ids]
            @investments = Budget::Investment.where(id: params[:investments_ids])
          end
        end

        sig { void }
        def load_heading
          @heading = @investment.heading
        end

        sig { void }
        def load_categories
          @categories = Tag.category.order(:name)
        end
    end
  end
end
