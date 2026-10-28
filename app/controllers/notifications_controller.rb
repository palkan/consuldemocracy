# typed: true
class NotificationsController < ApplicationController
  before_action :authenticate_user!
  skip_authorization_check

  respond_to :html, :js

  sig { void }
  def index
    @notifications = T.must(current_user).notifications.unread
  end

  sig { void }
  def show
    @notification = T.must(current_user).notifications.find(params[:id])
    @notification.mark_as_read
    redirect_to linkable_resource_path(@notification), allow_other_host: true
  end

  sig { void }
  def read
    @notifications = T.must(current_user).notifications.read
  end

  sig { void }
  def mark_all_as_read
    T.must(current_user).notifications.unread.each(&:mark_as_read)
    redirect_to notifications_path
  end

  sig { void }
  def mark_as_read
    @notification = T.must(current_user).notifications.find(params[:id])
    @notification.mark_as_read
  end

  sig { void }
  def mark_as_unread
    @notification = T.must(current_user).notifications.find(params[:id])
    @notification.mark_as_unread
  end

  private

    sig { params(notification: Notification).returns(String) }
    def linkable_resource_path(notification)
      if notification.linkable_resource.is_a?(AdminNotification)
        notification.linkable_resource.link || notifications_path
      else
        polymorphic_path(notification.linkable_resource)
      end
    end
end
