# typed: strict
class SDGManagement::CardsController < SDGManagement::BaseController
  include Admin::Widget::CardsActions

  helper_method :index_path

  load_and_authorize_resource :phase, class: "SDG::Phase", id_param: "sdg_phase_id"
  load_and_authorize_resource :card, through: :phase, class: "Widget::Card"

  private

    sig { override.returns(String) }
    def index_path
      sdg_management_homepage_path
    end
end
