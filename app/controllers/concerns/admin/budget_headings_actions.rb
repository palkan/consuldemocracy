# typed: true
module Admin::BudgetHeadingsActions
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
    before_action :load_group
    before_action :load_heading, only: [:edit, :update, :destroy]
  end

  sig { void }
  def edit
  end

  sig { void }
  def create
    @heading = @group.headings.new(budget_heading_params)
    if @heading.save
      redirect_to headings_index, notice: t("admin.budget_headings.create.notice")
    else
      render new_action
    end
  end

  sig { void }
  def update
    if @heading.update(budget_heading_params)
      redirect_to headings_index, notice: t("admin.budget_headings.update.notice")
    else
      render :edit
    end
  end

  sig { void }
  def destroy
    if @heading.can_be_deleted?
      @heading.destroy!
      redirect_to headings_index, notice: t("admin.budget_headings.destroy.success_notice")
    else
      redirect_to headings_index, alert: t("admin.budget_headings.destroy.unable_notice")
    end
  end

  private

    sig { void }
    def load_budget
      @budget = Budget.find_by_slug_or_id! params[:budget_id]
    end

    sig { void }
    def load_group
      @group = @budget.groups.find_by_slug_or_id! params[:group_id]
    end

    sig { void }
    def load_heading
      @heading = @group.headings.find_by_slug_or_id! params[:id]
    end

    sig { returns(ActionController::Parameters) }
    def budget_heading_params
      params.require(:budget_heading).permit(allowed_params)
    end

    sig { returns(T::Array[T.untyped]) }
    def allowed_params
      valid_attributes = [:price, :population, :allow_custom_content, :latitude, :longitude,
                          :max_ballot_lines, :geozone_id]

      [*valid_attributes, translation_params(Budget::Heading)]
    end

    sig { abstract.returns(String) }
    def headings_index; end

    sig { abstract.returns(Symbol) }
    def new_action; end
end
