# typed: true
class Officing::VotersController < Officing::BaseController
  respond_to :html, :js

  before_action :load_officer_assignment
  before_action :verify_officer_assignment
  before_action :verify_booth

  sig { void }
  def new
    @user = User.find(params[:id])
    @polls = T.must(current_booth).polls.current
  end

  sig { void }
  def create
    @poll = Poll.find(voter_params[:poll_id])
    @user = User.find(voter_params[:user_id])

    @voter = Poll::Voter.create_with(
      document_type: @user.document_type,
      document_number: @user.document_number,
      origin: "booth",
      officer: T.must(current_user).poll_officer,
      booth_assignment: T.must(current_booth).booth_assignments.find_by(poll: @poll),
      officer_assignment: officer_assignment(@poll)
    ).find_or_create_by!(user: @user, poll: @poll)
  end

  private

    sig { returns(ActionController::Parameters) }
    def voter_params
      params.require(:voter).permit(:poll_id, :user_id)
    end

    sig { params(poll: Poll).returns(T.nilable(Poll::OfficerAssignment)) }
    def officer_assignment(poll)
      Poll::OfficerAssignment.by_officer(T.must(current_user).poll_officer)
                             .by_poll(poll)
                             .by_booth(current_booth)
                             .by_date(Date.current)
                             .find_by(final: false)
    end
end
