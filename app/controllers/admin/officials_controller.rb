# typed: true
class Admin::OfficialsController < Admin::BaseController
  sig { void }
  def index
    @officials = User.officials.page(params[:page]).for_render
  end

  sig { void }
  def search
    @users = User.search(params[:search]).page(params[:page]).for_render
  end

  sig { void }
  def edit
    @user = User.find(params[:id])
  end

  sig { void }
  def update
    @user = User.find(params[:id])
    @user.update!(user_params)
    redirect_to admin_officials_path, notice: t("admin.officials.flash.official_updated")
  end

  sig { void }
  def destroy
    @official = User.officials.find(params[:id])
    @official.remove_official_position!
    redirect_to admin_officials_path, notice: t("admin.officials.flash.official_destroyed")
  end

  private

    sig { returns(ActionController::Parameters) }
    def user_params
      params.require(:user).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      [:official_position, :official_level]
    end
end
