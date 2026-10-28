# typed: true
class ProposalNotificationsController < ApplicationController
  load_and_authorize_resource except: [:new]

  sig { void }
  def new
    @proposal = Proposal.find(params[:proposal_id])
    @notification = ProposalNotification.new(proposal_id: @proposal.id)
    authorize! :new, @notification
  end

  sig { void }
  def create
    @notification = ProposalNotification.new(proposal_notification_params)
    @proposal = Proposal.find(proposal_notification_params[:proposal_id])
    if @notification.save
      @proposal.notify_users(@notification)

      redirect_to @notification, notice: I18n.t("flash.actions.create.proposal_notification")
    else
      render :new
    end
  end

  sig { void }
  def show
    @notification = ProposalNotification.find(params[:id])
  end

  private

    sig { returns(ActionController::Parameters) }
    def proposal_notification_params
      params.require(:proposal_notification).permit(allowed_params)
    end

    sig { returns(T::Array[T.untyped]) }
    def allowed_params
      [:title, :body, :proposal_id]
    end
end
