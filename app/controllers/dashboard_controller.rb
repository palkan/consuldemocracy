# typed: true
class DashboardController < Dashboard::BaseController
  helper_method :dashboard_action, :course
  before_action :set_done_and_pending_actions, only: [:recommended_actions, :progress]
  before_action :authorize_dashboard, except: :publish

  sig { void }
  def show
  end

  sig { void }
  def publish
    authorize! :publish, proposal

    proposal.publish
    redirect_to progress_proposal_dashboard_path(proposal), notice: t("proposals.notice.published")
  end

  sig { void }
  def progress
  end

  sig { void }
  def community
  end

  sig { void }
  def recommended_actions
  end

  sig { void }
  def messages
  end

  sig { void }
  def related_content
  end

  private

    sig { returns(Dashboard::Action::PrivateRelation) }
    def course
      @course ||= Dashboard::Action.course_for(proposal)
    end

    sig { void }
    def set_done_and_pending_actions
      @done_actions = proposed_actions.joins(:proposals).where(proposals: { id: proposal.id })
      @pending_actions = proposed_actions - @done_actions
    end

    sig { void }
    def authorize_dashboard
      authorize! :dashboard, proposal
    end
end
