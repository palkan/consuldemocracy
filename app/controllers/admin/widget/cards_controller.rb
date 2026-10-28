# typed: true
class Admin::Widget::CardsController < Admin::BaseController
  include Admin::Widget::CardsActions

  load_and_authorize_resource :card, class: "Widget::Card"
  helper_method :index_path

  private

    sig { override.returns(String) }

    def index_path
      admin_homepage_path
    end
end
