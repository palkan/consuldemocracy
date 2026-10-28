# typed: true
module Admin::BudgetPhasesActions
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ActionController::Base }

  abstract!

  include Translatable
  include ImageAttributes

  included do
    before_action :load_budget
    before_action :load_phase, only: [:edit, :update, :enable, :disable]
  end

  sig { void }
  def edit
  end

  sig { void }
  def update
    if @phase.update(budget_phase_params)
      redirect_to phases_index, notice: t("flash.actions.save_changes.notice")
    else
      render :edit
    end
  end

  sig { void }
  def enable
    @phase.update!(enabled: true)

    respond_to do |format|
      format.html { redirect_to phases_index, notice: t("flash.actions.save_changes.notice") }
      format.js { render template: "admin/budgets_wizard/phases/toggle_enabled" }
    end
  end

  sig { void }
  def disable
    @phase.update!(enabled: false)

    respond_to do |format|
      format.html { redirect_to phases_index, notice: t("flash.actions.save_changes.notice") }
      format.js { render template: "admin/budgets_wizard/phases/toggle_enabled" }
    end
  end

  private

    sig { void }
    def load_budget
      @budget = Budget.find_by_slug_or_id!(params[:budget_id])
    end

    sig { void }
    def load_phase
      @phase = @budget.phases.find(params[:id])
    end

    sig { returns(ActionController::Parameters) }
    def budget_phase_params
      params.require(:budget_phase).permit(allowed_params)
    end

    sig { returns(T::Array[T.untyped]) }
    def allowed_params
      valid_attributes = [:starts_at, :ends_at, :enabled,
                          image_attributes: image_attributes]

      [*valid_attributes, translation_params(Budget::Phase)]
    end

    sig { abstract.returns(String) }
    def phases_index; end
end
