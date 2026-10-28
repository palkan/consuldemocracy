# typed: true
class SDG::GoalsController < ApplicationController
  include FeatureFlags

  feature_flag :sdg
  load_and_authorize_resource find_by: :code, id_param: :code

  sig { void }
  def index
    @goals = @goals.order(:code)
    @phases = SDG::Phase.accessible_by(current_ability).order(:kind)
    @header = WebSection.find_by!(name: "sdg").header
  end

  sig { void }
  def show
  end

  sig { void }
  def help
    @goals = @goals.order(:code)
  end
end
