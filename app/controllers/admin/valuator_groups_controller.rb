# typed: true
class Admin::ValuatorGroupsController < Admin::BaseController
  sig { void }
  def index
    @groups = ValuatorGroup.page(params[:page])
  end

  sig { void }
  def show
    @group = ValuatorGroup.find(params[:id])
  end

  sig { void }
  def new
    @group = ValuatorGroup.new
  end

  sig { void }
  def edit
    @group = ValuatorGroup.find(params[:id])
  end

  sig { void }
  def create
    @group = ValuatorGroup.new(group_params)
    if @group.save
      notice = t("flash.actions.create.valuator_group")
      redirect_to [:admin, :valuator_groups], notice: notice
    else
      render :new
    end
  end

  sig { void }
  def update
    @group = ValuatorGroup.find(params[:id])
    if @group.update(group_params)
      notice = t("flash.actions.update.valuator_group")
      redirect_to [:admin, @group], notice: notice
    else
      render :edit
    end
  end

  sig { void }
  def destroy
    @group = ValuatorGroup.find(params[:id])
    @group.destroy!
    notice = t("flash.actions.destroy.valuator_group")
    redirect_to [:admin, :valuator_groups], notice: notice
  end

  private

    sig { returns(ActionController::Parameters) }
    def group_params
      params.require(:valuator_group).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      [:name]
    end
end
