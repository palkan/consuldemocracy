# typed: true
class Admin::ModeratorsController < Admin::BaseController
  load_and_authorize_resource

  sig { void }
  def index
    @moderators = @moderators.page(params[:page])
  end

  sig { void }
  def search
    @users = User.search(params[:search]).includes(:moderator).page(params[:page])
  end

  sig { void }
  def create
    @moderator.user_id = params[:user_id]
    @moderator.save!

    redirect_to admin_moderators_path
  end

  sig { void }
  def destroy
    @moderator.destroy!
    redirect_to admin_moderators_path
  end
end
