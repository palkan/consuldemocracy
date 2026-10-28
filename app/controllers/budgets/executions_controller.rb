# typed: true
module Budgets
  class ExecutionsController < ApplicationController
    before_action :load_budget

    authorize_resource :budget

    sig { void }
    def show
      authorize! :read_executions, @budget
      @statuses = Milestone::Status.all
      @investments_by_heading = investments_by_heading_ordered_alphabetically.to_h
    end

    private

      sig { returns(T::Hash[T.nilable(Budget::Heading), T::Array[Budget::Investment]]) }
      def investments_by_heading
        base = @budget.investments.winners
        base = base.joins(milestones: :translations).includes(:milestones)
        base = base.tagged_with(params[:milestone_tag]) if params[:milestone_tag].present?

        if params[:status].present?
          base = base.with_milestone_status_id(params[:status])
          base.uniq.group_by(&:heading)
        else
          base.distinct.group_by(&:heading)
        end
      end

      sig { void }
      def load_budget
        @budget = Budget.find_by_slug_or_id params[:budget_id]
      end

      sig { returns(T::Array[[T.nilable(Budget::Heading), T::Array[Budget::Investment]]]) }
      def investments_by_heading_ordered_alphabetically
        investments_by_heading.sort { |a, b| T.must(a[0]).name <=> T.must(b[0]).name }
      end
  end
end
