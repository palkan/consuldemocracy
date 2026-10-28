# typed: true
class Officing::BallotSheetsController < Officing::BaseController
  before_action :verify_booth
  before_action :load_poll
  before_action :load_officer_assignments, only: [:new, :create]

  sig { void }
  def index
    load_ballot_sheets
  end

  sig { void }
  def show
    load_ballot_sheet
  end

  sig { void }
  def new
  end

  sig { void }
  def create
    load_officer_assignment

    @ballot_sheet = Poll::BallotSheet.new(ballot_sheet_params)

    if @ballot_sheet.save
      redirect_to officing_poll_ballot_sheet_path(@poll, @ballot_sheet)
    else
      flash.now[:alert] = @ballot_sheet.errors.full_messages.join(", ")
      render :new
    end
  end

  private

    sig { void }
    def load_poll
      @poll = Poll.find(params[:poll_id])
    end

    sig { void }
    def load_ballot_sheets
      @ballot_sheets = Poll::BallotSheet.where(poll: @poll)
    end

    sig { void }
    def load_ballot_sheet
      @ballot_sheet = Poll::BallotSheet.find(params[:id])
    end

    sig { void }
    def load_officer_assignments
      @officer_assignments = ::Poll::OfficerAssignment
                             .includes(booth_assignment: [:booth])
                             .joins(:booth_assignment)
                             .final
                             .where(id: T.must(T.must(current_user).poll_officer).officer_assignment_ids)
                             .where(poll_booth_assignments: { poll_id: @poll.id })
                             .where(date: Date.current)
    end

    sig { void }
    def load_officer_assignment
      @officer_assignment = T.must(T.must(current_user).poll_officer).officer_assignments.final
                                        .find_by(id: ballot_sheet_params[:officer_assignment_id])
    end

    sig { returns(ActionController::Parameters) }
    def ballot_sheet_params
      params.permit(allowed_params)
    end

    sig { returns(T::Array[T.untyped]) }
    def allowed_params
      [:data, :poll_id, :officer_assignment_id]
    end
end
