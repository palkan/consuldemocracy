# typed: true
class Admin::AdministratorsController < Admin::BaseController
  load_and_authorize_resource

  sig { void }
  def index
    @administrators = @administrators.page(params[:page])
  end

  sig { void }
  def search
    @users = User.search(params[:search]).includes(:administrator).page(params[:page])
  end

  sig { void }
  def create
    @administrator.user_id = params[:user_id]
    @administrator.save!

    redirect_to admin_administrators_path
  end

  sig { void }
  def destroy
    if T.must(current_user).id == @administrator.user_id
      flash[:error] = I18n.t("admin.administrators.administrator.restricted_removal")
    else
      @administrator.destroy
    end

    redirect_to admin_administrators_path
  end

  sig { void }
  def edit
  end

  sig { void }
  def update
    if @administrator.update(update_administrator_params)
      notice = t("admin.administrators.form.updated")
      redirect_to admin_administrators_path, notice: notice
    else
      render :edit
    end
  end

  private

    sig { returns(ActionController::Parameters) }
    def update_administrator_params
      params.require(:administrator).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      [:description]
    end
end
