# typed: true
class Management::ProposalsController < Management::BaseController
  include HasOrders
  include SearchAndFilter
  include Translatable
  include MapLocationAttributes

  before_action :only_verified_users, except: :print
  before_action :set_proposal, only: [:vote, :show]

  has_orders %w[confidence_score hot_score created_at most_commented random], only: [:index, :print]
  has_orders %w[most_voted newest], only: :show

  sig { void }
  def index
    @proposals = search_and_filter(Proposal.all)
    @remote_translation_resources = @proposals
  end

  sig { void }
  def new
    @proposal = Proposal.new
  end

  sig { void }
  def create
    @proposal = Proposal.new(proposal_params.merge(author: current_user, published_at: Time.current))

    if @proposal.save
      redirect_path = url_for(controller: controller_name, action: :show, id: @proposal.id)
      redirect_to redirect_path, notice: t("flash.actions.create.proposal")
    else
      render :new
    end
  end

  sig { void }
  def show
    @remote_translation_resources = @proposal
    @notifications = @proposal.notifications

    if request.path != management_proposal_path(@proposal)
      redirect_to management_proposal_path(@proposal), status: :moved_permanently
    end
  end

  sig { void }
  def vote
    @follow = Follow.find_or_create_by!(user: current_user, followable: @proposal)
    @proposal.register_vote(managed_user, "yes")
  end

  sig { void }
  def print
    @proposals = Proposal.send("sort_by_#{@current_order}").for_render.limit(5)
  end

  private

    sig { void }
    def set_proposal
      @proposal = Proposal.find(params[:id])
    end

    sig { returns(ActionController::Parameters) }
    def proposal_params
      params.require(:proposal).permit(allowed_params)
    end

    sig { returns(T::Array[T.untyped]) }
    def allowed_params
      attributes = [:video_url, :responsible_name, :tag_list,
                    :terms_of_service, :geozone_id,
                    map_location_attributes: map_location_attributes]

      [*attributes, translation_params(Proposal)]
    end

    sig { void }
    def only_verified_users
      check_verified_user t("management.proposals.alert.unverified_user")
    end
end
