# typed: true
class Admin::BudgetsController < Admin::BaseController
  include Translatable
  include ReportAttributes
  include ImageAttributes
  include FeatureFlags

  feature_flag :budgets

  has_filters %w[all open finished], only: :index

  before_action :load_budget, except: [:index]
  load_and_authorize_resource

  sig { void }
  def index
    @budgets = Budget.send(@current_filter).order(created_at: :desc).page(params[:page])
  end

  sig { void }
  def show
  end

  sig { void }
  def edit
  end

  sig { void }
  def publish
    @budget.publish!
    redirect_to admin_budget_path(@budget), notice: t("admin.budgets.publish.notice")
  end

  sig { void }
  def calculate_winners
    @budget.headings.each { |heading| Budget::Result.new(@budget, heading).delay.calculate_winners }
    redirect_to admin_budget_budget_investments_path(
                  budget_id: @budget.id,
                  advanced_filters: ["winners"]
                ),
                notice: I18n.t("admin.budgets.winners.calculated")
  end

  sig { void }
  def update
    if @budget.update(budget_params)
      redirect_to admin_budget_path(@budget), notice: t("admin.budgets.update.notice")
    else
      render :edit
    end
  end

  sig { void }
  def destroy
    if @budget.investments.any?
      redirect_to admin_budget_path(@budget), alert: t("admin.budgets.destroy.unable_notice")
    elsif @budget.poll.present?
      redirect_to admin_budget_path(@budget), alert: t("admin.budgets.destroy.unable_notice_polls")
    else
      @budget.destroy!
      redirect_to admin_budgets_path, notice: t("admin.budgets.destroy.success_notice")
    end
  end

  private

    sig { returns(ActionController::Parameters) }
    def budget_params
      params.require(:budget).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      descriptions = Budget::Phase::PHASE_KINDS.map { |p| "description_#{p}" }.map(&:to_sym)
      valid_attributes = [
        :phase,
        :currency_symbol,
        :voting_style,
        :hide_money,
        administrator_ids: [],
        valuator_ids: [],
        image_attributes: image_attributes
      ] + descriptions

      [*valid_attributes, *report_attributes, translation_params(Budget)]
    end

    sig { void }
    def load_budget
      @budget = Budget.find_by_slug_or_id! params[:id]
    end
end
