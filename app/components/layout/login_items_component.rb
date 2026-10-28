# typed: strict
class Layout::LoginItemsComponent < ApplicationComponent
  sig { returns(T.nilable(User)) }
  attr_reader :user

  delegate :layout_menu_link_to, to: :helpers

  sig { params(user: T.nilable(User)).void }
  def initialize(user)
    @user = user
  end

  private

    sig { returns(T::Boolean) }
    def show_my_activity_link?
      !Rails.application.multitenancy_management_mode?
    end
end
