# typed: true
class Admin::HiddenUsersController < Admin::BaseController
  include Admin::HiddenContent

  before_action :load_user, only: [:confirm_hide, :restore]

  sig { void }
  def index
    @users = hidden_content(User.all)
  end

  sig { void }
  def show
    @user = User.with_hidden.find(params[:id])
    @debates = @user.debates.with_hidden.page(params[:page])
    @comments = @user.comments.with_hidden.page(params[:page])
  end

  sig { void }
  def confirm_hide
    @user.confirm_hide
    redirect_with_query_params_to(action: :index)
  end

  sig { void }
  def restore
    @user.full_restore
    Activity.log(current_user, :restore, @user)
    redirect_with_query_params_to(action: :index)
  end

  private

    sig { void }
    def load_user
      @user = User.with_hidden.find(params[:id])
    end
end
