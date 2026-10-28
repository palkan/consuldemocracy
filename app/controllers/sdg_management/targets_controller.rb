# typed: true
class SDGManagement::TargetsController < SDGManagement::BaseController
  load_and_authorize_resource class: "SDG::Target"

  sig { void }
  def index
    @targets = @targets.sort
  end
end
