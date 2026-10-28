# typed: true
class Admin::HiddenDebatesController < Admin::BaseController
  include FeatureFlags
  include Admin::HiddenContent

  feature_flag :debates

  before_action :load_debate, only: [:confirm_hide, :restore]

  sig { void }
  def index
    @debates = hidden_content(Debate.all)
  end

  sig { void }
  def confirm_hide
    @debate.confirm_hide
    redirect_with_query_params_to(action: :index)
  end

  sig { void }
  def restore
    @debate.restore!(recursive: true)
    @debate.ignore_flag
    Activity.log(current_user, :restore, @debate)
    redirect_with_query_params_to(action: :index)
  end

  private

    sig { void }
    def load_debate
      @debate = Debate.with_hidden.find(params[:id])
    end
end
