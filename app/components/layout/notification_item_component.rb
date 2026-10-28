# typed: strict
class Layout::NotificationItemComponent < ApplicationComponent
  sig { returns(T.nilable(User)) }
  attr_reader :user

  sig { params(user: T.nilable(User)).void }
  def initialize(user)
    @user = user
  end

  sig { returns(T::Boolean) }
  def render?
    user.present? && !Rails.application.multitenancy_management_mode?
  end

  private

    sig { returns(String) }
    def text
      t("layouts.header.notification_item.new_notifications", count: unread_notifications.count)
    end

    sig { returns(String) }
    def notifications_class
      if unread_notifications.any?
        "unread-notifications"
      else
        "no-notifications"
      end
    end

    sig { returns(Notification::PrivateAssociationRelation) }
    def unread_notifications
      T.must(user).notifications.unread
    end
end
