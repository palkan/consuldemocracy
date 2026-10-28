# typed: true
module Admin::BudgetGroupsActions
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ActionController::Base }

  abstract!

  include Translatable
  include FeatureFlags

  included do
    feature_flag :budgets

    before_action :load_budget
    before_action :load_group, only: [:edit, :update, :destroy]
  end

  sig { void }
  def edit
  end

  sig { void }
  def create
    @group = @budget.groups.new(budget_group_params)
    if @group.save
      redirect_to groups_index, notice: t("admin.budget_groups.create.notice")
    else
      render new_action
    end
  end

  sig { void }
  def update
    if @group.update(budget_group_params)
      redirect_to groups_index, notice: t("admin.budget_groups.update.notice")
    else
      render :edit
    end
  end

  sig { void }
  def destroy
    if @group.headings.any?
      redirect_to groups_index, alert: t("admin.budget_groups.destroy.unable_notice")
    else
      @group.destroy!
      redirect_to groups_index, notice: t("admin.budget_groups.destroy.success_notice")
    end
  end

  private

    sig { void }
    def load_budget
      @budget = Budget.find_by_slug_or_id! params[:budget_id]
    end

    sig { void }
    def load_groups
      @groups = @budget.groups.order(:id)
    end

    sig { void }
    def load_group
      @group = @budget.groups.find_by_slug_or_id! params[:id]
    end

    sig { returns(ActionController::Parameters) }
    def budget_group_params
      params.require(:budget_group).permit(allowed_params)
    end

    sig { returns(T::Array[T.untyped]) }
    def allowed_params
      valid_attributes = [:max_votable_headings]

      [*valid_attributes, translation_params(Budget::Group)]
    end

    sig { abstract.returns(String) }
    def groups_index; end

    sig { abstract.returns(Symbol) }
    def new_action; end
end
