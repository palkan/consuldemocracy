# typed: true
class Admin::VerificationsController < Admin::BaseController
  sig { void }
  def index
    @users = User.incomplete_verification.page(params[:page])
  end

  sig { void }
  def search
    @users = User.incomplete_verification
                 .search(params[:search])
                 .page(params[:page])
                 .for_render
    render :index
  end
end
