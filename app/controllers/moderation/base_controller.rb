# typed: strict
class Moderation::BaseController < ApplicationController
  layout "admin"

  before_action :authenticate_user!
  before_action :verify_moderator

  skip_authorization_check

  private

    sig { void }
    def verify_moderator
      raise CanCan::AccessDenied unless current_user&.moderator? || current_user&.administrator?
    end
end
