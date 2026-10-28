# typed: true
class SDGManagement::GoalsController < SDGManagement::BaseController
  load_and_authorize_resource class: "SDG::Goal"

  sig { void }
  def index
    @goals = @goals.order(:code)
  end
end
