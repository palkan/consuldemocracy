# typed: true
class Users::SessionsController < Devise::SessionsController
  sig { void }
  def destroy
    @stored_location = stored_location_for(:user)
    super
  end

  private

    sig { params(resource: T.untyped).returns(String) }
    def after_sign_in_path_for(resource)
      if Rails.application.multitenancy_management_mode? && !resource.administrator?
        account_path
      elsif !verifying_via_email? && resource.show_welcome_screen?
        welcome_path
      else
        super
      end
    end

    sig { params(resource: T.untyped).returns(String) }
    def after_sign_out_path_for(resource)
      @stored_location.present? && !@stored_location.match("management") ? @stored_location : super
    end

    sig { returns(T::Boolean) }
    def verifying_via_email?
      return false if resource.blank?

      stored_path = session[stored_location_key_for(resource)] || ""
      stored_path[0..5] == "/email"
    end
end
