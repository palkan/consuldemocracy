# typed: strict
class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_action :authenticate_scope!,
                        only: [:edit, :update, :destroy, :finish_signup, :do_finish_signup]
  before_action :configure_permitted_parameters

  invisible_captcha only: [:create], honeypot: :address, scope: :user

  sig { void }
  def new
    super
  end

  sig { void }
  def create
    build_resource(sign_up_params)
    resource.registering_from_web = true

    if resource.valid?
      super
    else
      render :new
    end
  end

  sig { void }
  def delete_form
    build_resource({})
  end

  sig { void }
  def delete
    T.must(current_user).erase(erase_params[:erase_reason])
    sign_out
    redirect_to root_path, notice: t("devise.registrations.destroyed")
  end

  sig { void }
  def success
  end

  sig { void }
  def finish_signup
    user = T.must(current_user)
    user.registering_with_oauth = false
    user.email = user.oauth_email if user.email.blank?
    user.validate
  end

  sig { void }
  def do_finish_signup
    user = T.must(current_user)
    user.registering_with_oauth = false
    if user.update(sign_up_params)
      user.send_oauth_confirmation_instructions
      sign_in_and_redirect user, event: :authentication
    else
      render :finish_signup
    end
  end

  sig { void }
  def check_username
    if User.find_by username: params[:username]
      render json: { available: false,
                     message: t("devise_views.users.registrations.new.username_is_not_available") }
    else
      render json: { available: true,
                     message: t("devise_views.users.registrations.new.username_is_available") }
    end
  end

  private

    sig { returns(ActionController::Parameters) }
    def sign_up_params
      params.require(:user).permit(allowed_params)
    end

    sig { returns(T::Array[T.untyped]) }
    def allowed_params
      [
        :username, :email, :password,
        :password_confirmation, :terms_of_service, :locale
      ]
    end

    sig { void }
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:account_update, keys: [:email])
    end

    sig { returns(ActionController::Parameters) }
    def erase_params
      params.require(:user).permit(:erase_reason)
    end

    sig { params(resource_or_scope: T.untyped).returns(String) }
    def after_inactive_sign_up_path_for(resource_or_scope)
      users_sign_up_success_path
    end
end
