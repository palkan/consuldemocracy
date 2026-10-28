# typed: true
class Admin::Poll::BoothAssignmentsController < Admin::Poll::BaseController
  before_action :load_poll, except: [:create]

  sig { void }
  def index
    @booth_assignments = @poll.booth_assignments.includes(:booth).order("poll_booths.name")
                              .page(params[:page]).per(50)
  end

  sig { void }
  def search_booths
    load_search
    @booths = ::Poll::Booth.quick_search(@search)
    respond_to do |format|
      format.js
    end
  end

  sig { void }
  def show
    included_relations = [:recounts, :voters, officer_assignments: [officer: [:user]]]
    @booth_assignment = @poll.booth_assignments.includes(*included_relations).find(params[:id])
    @voters_by_date = @booth_assignment.voters.group_by { |v| v.created_at.to_date }
    @partial_results = @booth_assignment.partial_results
    @recounts = @booth_assignment.recounts
  end

  sig { void }
  def create
    @poll = Poll.find(booth_assignment_params[:poll_id])
    @booth = Poll::Booth.find(booth_assignment_params[:booth_id])
    @booth_assignment = ::Poll::BoothAssignment.new(poll: @poll, booth: @booth)

    @booth_assignment.save!

    respond_to do |format|
      format.js { render layout: false }
    end
  end

  sig { void }
  def destroy
    @booth_assignment = @poll.booth_assignments.find(params[:id])
    @booth = @booth_assignment.booth

    @booth_assignment.destroy!

    respond_to do |format|
      format.js { render layout: false }
    end
  end

  sig { void }
  def manage
    @booths = ::Poll::Booth.order(name: :asc).page(params[:page]).per(300)
    @poll = Poll.find(params[:poll_id])
  end

  private

    sig { void }
    def load_booth_assignment
      @booth_assignment = ::Poll::BoothAssignment.find(params[:id])
    end

    sig { returns(ActionController::Parameters) }
    def booth_assignment_params
      params.permit(:booth_id, :poll_id)
    end

    sig { void }
    def load_poll
      @poll = ::Poll.find(params[:poll_id])
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
