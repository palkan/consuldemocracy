# typed: true
class ProposalsController < ApplicationController
  include FeatureFlags
  include SearchAndFilter
  include FlagActions
  include ImageAttributes
  include DocumentAttributes
  include MapLocationAttributes
  include Translatable

  before_action :load_categories, only: [:index, :map, :summary]
  before_action :load_geozones, only: :map
  before_action :authenticate_user!, except: [:index, :show, :map, :summary]
  before_action :proposals_recommendations, only: :index, if: :current_user

  feature_flag :proposals

  invisible_captcha only: [:create, :update], honeypot: :subtitle

  has_orders ->(c) { Proposal.proposals_orders(c.current_user) }, only: :index
  has_orders %w[most_voted newest oldest], only: :show

  load_and_authorize_resource
  before_action :destroy_map_location_association, only: :update

  respond_to :html, :js

  sig { void }
  def index
    @proposals = search_and_filter(Proposal.all)

    discard_draft
    discard_archived
    load_retired
    load_selected
    load_featured
    remove_archived_from_order_links
    @remote_translation_resources = [*@proposals, *@featured_proposals]
  end

  sig { void }
  def show
    @remote_translation_resources = @proposal
    @notifications = @proposal.notifications.not_moderated

    if request.path != proposal_path(@proposal)
      redirect_to proposal_path(@proposal), status: :moved_permanently
    end
  end

  sig { void }
  def new
    @proposal = Proposal.new
  end

  sig { void }
  def create
    @proposal = Proposal.new(proposal_params.merge(author: current_user))
    if @proposal.save
      redirect_to created_proposal_path(@proposal), notice: I18n.t("flash.actions.create.proposal")
    else
      render :new
    end
  end

  sig { void }
  def created; end

  sig { void }
  def suggest
    @proposals = Proposal.all
  end

  sig { void }
  def edit
  end

  sig { void }
  def update
    if @proposal.update(proposal_params)
      redirect_to proposal_path(@proposal), notice: t("flash.actions.update.proposal")
    else
      render :edit
    end
  end

  sig { void }
  def vote
    @follow = Follow.find_or_create_by!(user: current_user, followable: @proposal)
    @proposal.register_vote(current_user, "yes")
  end

  sig { void }
  def retire
    if @proposal.update(retired_params.merge(retired_at: Time.current))
      redirect_to proposal_path(@proposal), notice: t("proposals.notice.retired")
    else
      render action: :retire_form
    end
  end

  sig { void }
  def retire_form
  end

  sig { void }
  def summary
    @proposals = Proposal.for_summary
  end

  sig { void }
  def map
    @proposal = Proposal.new
  end

  sig { void }
  def disable_recommendations
    if T.must(current_user).update(recommended_proposals: false)
      redirect_to proposals_path, notice: t("proposals.index.recommendations.actions.success")
    else
      redirect_to proposals_path, error: t("proposals.index.recommendations.actions.error")
    end
  end

  sig { void }
  def publish
    @proposal.publish
    redirect_to share_proposal_path(@proposal), notice: t("proposals.notice.published")
  end

  private

    sig { returns(ActionController::Parameters) }
    def proposal_params
      params.require(:proposal).permit(allowed_params)
    end

    sig { returns(T::Array[T.untyped]) }
    def allowed_params
      attributes = [:video_url, :responsible_name, :tag_list, :terms_of_service,
                    :geozone_id, :related_sdg_list,
                    image_attributes: image_attributes,
                    documents_attributes: document_attributes,
                    map_location_attributes: map_location_attributes]
      translations_attributes = translation_params(Proposal, except: :retired_explanation)

      [*attributes, translations_attributes]
    end

    sig { returns(ActionController::Parameters) }
    def retired_params
      params.require(:proposal).permit(allowed_retired_params)
    end

    sig { returns(T::Array[T.untyped]) }
    def allowed_retired_params
      [:retired_reason, translation_params(Proposal, only: :retired_explanation)]
    end

    sig { override.returns(T.class_of(Proposal)) }
    def resource_model
      Proposal
    end

    sig { void }
    def discard_draft
      @proposals = @proposals.published
    end

    sig { void }
    def discard_archived
      unless @current_order == "archival_date" || params[:selected].present?
        @proposals = @proposals.not_archived
      end
    end

    sig { void }
    def load_retired
      if params[:retired].present?
        @proposals = @proposals.retired

        if Proposal::RETIRE_OPTIONS.include?(params[:retired])
          @proposals = @proposals.where(retired_reason: params[:retired])
        end
      else
        @proposals = @proposals.not_retired
      end
    end

    sig { void }
    def load_selected
      if params[:selected].present?
        @proposals = @proposals.selected
      else
        @proposals = @proposals.not_selected
      end
    end

    sig { void }
    def load_featured
      return if @advanced_search_terms || @search_terms.present? ||
                params[:retired].present? || @current_order == "recommendations"

      if Setting["feature.featured_proposals"]
        @featured_proposals = Proposal.not_archived
                                      .unsuccessful
                                      .sort_by_confidence_score
                                      .limit(Setting["featured_proposals_number"])
        if @featured_proposals.present?
          @proposals = @proposals.excluding(@featured_proposals)
        end
      end
    end

    sig { void }
    def load_geozones
      @geozones = Geozone.order(name: :asc)
    end

    sig { void }
    def load_categories
      @categories = Tag.category.order(:name)
    end

    sig { void }
    def remove_archived_from_order_links
      @valid_orders.delete("archival_date")
    end

    sig { void }
    def destroy_map_location_association
      map_location_params = proposal_params[:map_location_attributes]

      if map_location_params.blank? || map_location_params.values.all?(&:blank?)
        @proposal.map_location = nil
      end
    end

    sig { void }
    def proposals_recommendations
      if Setting["feature.user.recommendations_on_proposals"] && T.must(current_user).recommended_proposals
        @recommended_proposals = Proposal.recommendations(T.must(current_user)).sort_by_random.limit(3)
      end
    end
end
