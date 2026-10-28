# typed: true
class DebatesController < ApplicationController
  include FeatureFlags
  include SearchAndFilter
  include FlagActions
  include Translatable

  before_action :authenticate_user!, except: [:index, :show]
  before_action :debates_recommendations, only: :index, if: :current_user

  feature_flag :debates

  invisible_captcha only: [:create, :update], honeypot: :subtitle

  has_orders ->(c) { Debate.debates_orders(c.current_user) }, only: :index
  has_orders %w[most_voted newest oldest], only: :show

  load_and_authorize_resource
  respond_to :html, :js

  sig { void }
  def index
    @debates = search_and_filter(Debate.all)
    @featured_debates = T.cast(@debates, Debate::PrivateRelation).featured
    @remote_translation_resources = [*@debates, *@featured_debates]
  end

  sig { void }
  def new
    @debate = Debate.new
  end

  sig { void }
  def create
    @debate = Debate.new(debate_params)
    @debate.author = current_user

    if @debate.save
      redirect_to debate_path(@debate), notice: t("flash.actions.create.debate")
    else
      render :new
    end
  end

  sig { void }
  def suggest
    @debates = Debate.all
  end

  sig { void }
  def edit
  end

  sig { void }
  def update
    if @debate.update(debate_params)
      redirect_to debate_path(@debate), notice: t("flash.actions.update.debate")
    else
      render :edit
    end
  end

  sig { void }
  def show
    @remote_translation_resources = @debate

    redirect_to debate_path(@debate), status: :moved_permanently if request.path != debate_path(@debate)
  end

  sig { void }
  def unmark_featured
    @debate.update!(featured_at: nil)
    redirect_to debates_path
  end

  sig { void }
  def mark_featured
    @debate.update!(featured_at: Time.current)
    redirect_to debates_path
  end

  sig { void }
  def disable_recommendations
    if T.must(current_user).update(recommended_debates: false)
      redirect_to debates_path, notice: t("debates.index.recommendations.actions.success")
    else
      redirect_to debates_path, error: t("debates.index.recommendations.actions.error")
    end
  end

  private

    sig { returns(ActionController::Parameters) }
    def debate_params
      params.require(:debate).permit(allowed_params)
    end

    sig { returns(T::Array[T.untyped]) }
    def allowed_params
      [:tag_list, :terms_of_service, :related_sdg_list, translation_params(Debate)]
    end

    sig { override.returns(T.class_of(Debate)) }
    def resource_model
      Debate
    end

    sig { void }
    def debates_recommendations
      if Setting["feature.user.recommendations_on_debates"] && T.must(current_user).recommended_debates
        @recommended_debates = Debate.recommendations(T.must(current_user)).sort_by_random.limit(3)
      end
    end
end
