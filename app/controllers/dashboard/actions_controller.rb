# typed: true
class Dashboard::ActionsController < Dashboard::BaseController
  helper_method :dashboard_action

  sig { void }
  def new_request
    authorize! :dashboard, proposal
    @dashboard_executed_action = Dashboard::ExecutedAction.new
  end

  sig { void }
  def create_request
    authorize! :dashboard, proposal

    source_params = {
      proposal: proposal,
      action: dashboard_action,
      executed_at: Time.current
    }

    @dashboard_executed_action = Dashboard::ExecutedAction.new(source_params)
    if @dashboard_executed_action.save
      Dashboard::AdministratorTask.create!(source: @dashboard_executed_action)

      redirect_to progress_proposal_dashboard_path(proposal.to_param),
                  { flash: { info: t("dashboard.create_request.success") }}
    else
      flash.now[:alert] = @dashboard_executed_action.errors.full_messages.join("<br>")
      render :new_request
    end
  end

  sig { void }
  def execute
    authorize! :dashboard, proposal

    Dashboard::ExecutedAction.create(proposal: proposal,
                                     action: dashboard_action,
                                     executed_at: Time.current)
    redirect_to request.referer
  end

  sig { void }
  def unexecute
    authorize! :dashboard, proposal

    T.must(Dashboard::ExecutedAction.find_by(proposal: proposal, action: dashboard_action)).destroy!

    redirect_to request.referer
  end

  private

    sig { returns(Dashboard::Action) }
    def dashboard_action
      @dashboard_action ||= Dashboard::Action.find(params[:id])
    end
end
