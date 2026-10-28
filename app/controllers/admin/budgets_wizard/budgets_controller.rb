# typed: true
class Admin::BudgetsWizard::BudgetsController < Admin::BudgetsWizard::BaseController
  include Translatable
  include ImageAttributes
  include FeatureFlags

  feature_flag :budgets

  load_and_authorize_resource

  sig { void }
  def new
  end

  sig { void }
  def edit
  end

  sig { void }
  def create
    @budget.published = false

    if @budget.save
      redirect_to groups_index, notice: t("admin.budgets.create.notice")
    else
      render :new
    end
  end

  sig { void }
  def update
    if @budget.update(budget_params)
      redirect_to groups_index, notice: t("admin.budgets.update.notice")
    else
      render :edit
    end
  end

  private

    sig { returns(ActionController::Parameters) }
    def budget_params
      params.require(:budget).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      valid_attributes = [:currency_symbol, :voting_style, :hide_money,
                          administrator_ids: [],
                          valuator_ids: [],
                          image_attributes: image_attributes]

      [*valid_attributes, translation_params(Budget)]
    end

    sig { returns(String) }

    def groups_index
      admin_budgets_wizard_budget_groups_path(@budget, url_params)
    end
end
