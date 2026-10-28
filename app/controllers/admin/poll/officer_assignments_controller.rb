# typed: true
class Admin::Poll::OfficerAssignmentsController < Admin::Poll::BaseController
  before_action :load_poll
  before_action :redirect_if_blank_required_params, only: [:by_officer]

  sig { void }
  def index
    @officers = ::Poll::Officer
                .includes(:user)
                .order("users.username")
                .where(id: @poll.officer_assignments.distinct.pluck(:officer_id))
                .page(params[:page])
                .per(50)
  end

  sig { void }
  def by_officer
    @poll = ::Poll.includes(:booths).find(params[:poll_id])
    @officer = ::Poll::Officer.includes(:user).find(officer_assignment_params[:officer_id])
    @officer_assignments = ::Poll::OfficerAssignment
                           .joins(:booth_assignment)
                           .includes(:recounts, booth_assignment: :booth)
                           .by_officer_and_poll(@officer.id, @poll.id)
                           .order(:date)
  end

  sig { void }
  def search_officers
    load_search

    poll_officers = User.where(id: @poll.officers.pluck(:user_id))
    @officers = poll_officers.search(@search).order(username: :asc)

    respond_to do |format|
      format.js
    end
  end

  private

    sig { returns(ActionController::Parameters) }
    def officer_assignment_params
      params.permit(:officer_id)
    end

    sig { void }
    def load_poll
      @poll = ::Poll.find(params[:poll_id])
    end

    sig { void }
    def redirect_if_blank_required_params
      if officer_assignment_params[:officer_id].blank?
        redirect_to admin_poll_path(@poll)
      end
    end

    sig { returns(ActionController::Parameters) }

    def search_params
      params.permit(:poll_id, :search)
    end

    sig { void }
    def load_search
      @search = search_params[:search]
    end
end
