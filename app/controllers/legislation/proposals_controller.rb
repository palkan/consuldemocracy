# typed: true
class Legislation::ProposalsController < Legislation::BaseController
  include Search
  include FlagActions
  include ImageAttributes

  before_action :authenticate_user!, except: :show
  load_and_authorize_resource :process, class: "Legislation::Process"
  load_and_authorize_resource :proposal, class: "Legislation::Proposal", through: :process

  invisible_captcha only: [:create, :update], honeypot: :subtitle

  has_orders %w[most_voted newest oldest], only: :show

  respond_to :html, :js

  sig { void }
  def show
    @remote_translation_resources = @proposal
    @document = Document.new(documentable: @proposal)
    if request.path != legislation_process_proposal_path(params[:process_id], @proposal)
      redirect_to legislation_process_proposal_path(params[:process_id], @proposal),
                  status: :moved_permanently
    end
  end

  sig { void }
  def new
    @proposal = Legislation::Proposal.new
  end

  sig { void }
  def create
    @proposal = Legislation::Proposal.new(proposal_params.merge(author: current_user))

    if @proposal.save
      redirect_to legislation_process_proposal_path(params[:process_id], @proposal),
                  notice: I18n.t("flash.actions.create.proposal")
    else
      render :new
    end
  end

  sig { void }
  def suggest
    @proposals = @process.proposals
  end

  sig { void }
  def edit
  end

  sig { void }
  def update
    if @proposal.update(proposal_params)
      redirect_to legislation_process_proposal_path(params[:process_id], @proposal),
                  notice: t("flash.actions.update.proposal")
    else
      render :edit
    end
  end

  private

    sig { returns(ActionController::Parameters) }
    def proposal_params
      params.require(:legislation_proposal).permit(allowed_params)
    end

    sig { returns(T::Array[T.untyped]) }
    def allowed_params
      [
        :legislation_process_id, :title,
        :summary, :description, :video_url, :tag_list,
        :terms_of_service, :geozone_id,
        image_attributes: image_attributes,
        documents_attributes: [:id, :title, :attachment, :cached_attachment, :user_id]
      ]
    end

    sig { override.returns(T.class_of(Legislation::Proposal)) }
    def resource_model
      Legislation::Proposal
    end
end
