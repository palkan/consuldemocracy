# typed: strict
class Admin::Dashboard::Actions::FormComponent < ApplicationComponent
  sig { returns(Dashboard::Action) }
  attr_reader :dashboard_action

  sig { returns(String) }
  attr_reader :url_action

  sig { params(dashboard_action: Dashboard::Action, url_action: String).void }
  def initialize(dashboard_action, url_action:)
    @dashboard_action = dashboard_action
    @url_action = url_action
  end

  private

    sig { params(attribute: Symbol).returns(String) }
    def attribute_name(attribute)
      Dashboard::Action.human_attribute_name(attribute)
    end
end
