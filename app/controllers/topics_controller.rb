# typed: true
class TopicsController < ApplicationController
  before_action :load_community
  before_action :load_topic, only: [:show, :edit, :update, :destroy]

  has_orders %w[most_voted newest oldest], only: :show

  skip_authorization_check only: :show
  load_and_authorize_resource except: :show

  sig { void }
  def new
    @topic = Topic.new
  end

  sig { void }
  def create
    @topic = Topic.new(topic_params.merge(author: current_user, community_id: params[:community_id]))
    if @topic.save
      redirect_to community_path(@community), notice: I18n.t("flash.actions.create.topic")
    else
      render :new
    end
  end

  sig { void }
  def show
  end

  sig { void }
  def edit
  end

  sig { void }
  def update
    if @topic.update(topic_params)
      redirect_to community_path(@community), notice: t("flash.actions.update.topic")
    else
      render :edit
    end
  end

  sig { void }
  def destroy
    @topic.destroy!
    redirect_to community_path(@community), notice: I18n.t("flash.actions.destroy.topic")
  end

  private

    sig { returns(ActionController::Parameters) }
    def topic_params
      params.require(:topic).permit(allowed_params)
    end

    sig { returns(T::Array[T.untyped]) }
    def allowed_params
      [:title, :description]
    end

    sig { void }
    def load_community
      @community = Community.find(params[:community_id])
    end

    sig { void }
    def load_topic
      @topic = Topic.find(params[:id])
    end
end
