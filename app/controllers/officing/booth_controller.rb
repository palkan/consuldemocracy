# typed: true
class Officing::BoothController < Officing::BaseController
  before_action :load_officer_assignment
  before_action :verify_officer_assignment

  sig { void }
  def new
    @booths = T.must(T.must(current_user).poll_officer).todays_booths
  end

  sig { void }
  def create
    set_booth(Poll::Booth.find(booth_params[:id]))
    redirect_to officing_root_path
  end

  private

    sig { returns(ActionController::Parameters) }
    def booth_params
      params.require(:booth).permit(:id)
    end

    sig { params(booth: Poll::Booth).void }
    def set_booth(booth)
      session[:booth_id] = booth.id
    end
end
