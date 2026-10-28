# typed: true
class Officing::ResultsController < Officing::BaseController
  before_action :load_poll

  before_action :load_officer_assignments, only: :new
  before_action :load_partial_results, only: :new

  before_action :load_officer_assignment, only: :create
  before_action :check_officer_assignment, only: :create
  before_action :build_results, only: :create
  before_action :verify_booth

  sig { void }
  def new
  end

  sig { void }
  def create
    @results.each(&:save!)

    notice = t("officing.results.flash.create")
    redirect_to new_officing_poll_result_path(@poll), notice: notice
  end

  sig { void }
  def index
    @booth_assignment = ::Poll::BoothAssignment.includes(:booth).find(index_params[:booth_assignment_id])
    if T.must(T.must(current_user).poll_officer).officer_assignments.final
                   .where(booth_assignment_id: @booth_assignment.id).exists?

      @partial_results = ::Poll::PartialResult.includes(:question)
                                              .where(booth_assignment_id: index_params[:booth_assignment_id])
                                              .where(date: index_params[:date])
      @recounts = ::Poll::Recount.where(booth_assignment_id: @booth_assignment.id, date: index_params[:date])
    end
  end

  private

    sig { void }
    def build_results
      @results = []

      params[:questions].each_pair do |question_id, results|
        question = @poll.questions.find(question_id)

        results.each_pair do |option_id, count|
          next if count.blank?

          option = question.question_options.find_by(id: option_id)

          partial_result = ::Poll::PartialResult.find_or_initialize_by(
            booth_assignment_id: @officer_assignment.booth_assignment_id,
            date: Date.current,
            question_id: question_id,
            option_id: option.id
          )
          partial_result.officer_assignment_id = @officer_assignment.id
          partial_result.amount = count.to_i
          partial_result.author = current_user
          partial_result.origin = "booth"
          @results << partial_result
        end
      end

      build_recounts
    end

    sig { void }
    def build_recounts
      recount = ::Poll::Recount.find_or_initialize_by(
        booth_assignment_id: @officer_assignment.booth_assignment_id,
        date: Date.current
      )
      recount.officer_assignment_id = @officer_assignment.id
      recount.author = current_user
      recount.origin = "booth"
      [:whites, :nulls, :total].each do |recount_type|
        if results_params[recount_type].present?
          recount["#{recount_type.to_s.singularize}_amount"] = results_params[recount_type].to_i
        end
      end
      @results << recount
    end

    sig { params(alert: String).void }
    def go_back_to_new(alert)
      params[:d] = Date.current
      params[:oa] = results_params[:officer_assignment_id]
      flash.now[:alert] = alert
      load_officer_assignments
      load_partial_results
      render :new
    end

    sig { void }
    def load_poll
      @poll = ::Poll.includes(:questions).find(params[:poll_id])
    end

    sig { void }
    def load_officer_assignment
      @officer_assignment = T.must(T.must(current_user).poll_officer)
                                        .officer_assignments
                                        .final
                                        .find_by(id: results_params[:officer_assignment_id])
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
    def load_partial_results
      if @officer_assignments.present?
        @partial_results = ::Poll::PartialResult.where(officer_assignment_id: @officer_assignments.map(&:id))
                                                .order(:booth_assignment_id, :date)
      end
    end

    sig { returns(ActionController::Parameters) }
    def results_params
      params.permit(:officer_assignment_id, :questions, :whites, :nulls, :total)
    end

    sig { returns(ActionController::Parameters) }
    def index_params
      params.permit(:booth_assignment_id, :date)
    end

    sig { void }
    def check_officer_assignment
      if @officer_assignment.blank?
        go_back_to_new(t("officing.results.flash.error_wrong_booth"))
      end
    end
end
