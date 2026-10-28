# typed: true
class Admin::MilestoneStatusesController < Admin::BaseController
  before_action :load_status, only: [:edit, :update, :destroy]

  sig { void }
  def index
    @statuses = Milestone::Status.all
  end

  sig { void }
  def new
    @status = Milestone::Status.new
  end

  sig { void }
  def create
    @status = Milestone::Status.new(status_params)

    if @status.save
      redirect_to admin_milestone_statuses_path, notice: t("admin.statuses.create.notice")
    else
      render :new
    end
  end

  sig { void }
  def edit
  end

  sig { void }
  def update
    if @status.update(status_params)
      redirect_to admin_milestone_statuses_path, notice: t("admin.statuses.update.notice")
    else
      render :edit
    end
  end

  sig { void }
  def destroy
    @status.destroy!
    redirect_to admin_milestone_statuses_path, notice: t("admin.statuses.delete.notice")
  end

  private

    sig { void }
    def load_status
      @status = Milestone::Status.find(params[:id])
    end

    sig { returns(ActionController::Parameters) }
    def status_params
      params.require(:milestone_status).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      [:name, :description]
    end
end
