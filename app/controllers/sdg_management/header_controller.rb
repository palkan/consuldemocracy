# typed: true
class SDGManagement::HeaderController < SDGManagement::BaseController
  include Admin::Widget::CardsActions

  helper_method :index_path

  before_action :load_cardable
  load_and_authorize_resource :header,
                              class: "Widget::Card",
                              through: :cardable,
                              singleton: true,
                              instance_name: :card

  private

    sig { void }
    def load_cardable
      @cardable = WebSection.find_by!(name: "sdg")
    end

    sig { override.returns(String) }
    def index_path
      sdg_management_homepage_path
    end

    sig { returns(String) }
    def form_path
      sdg_management_homepage_header_path
    end

    sig { returns(ActionController::Parameters) }
    def header_params
      card_params
    end
end
