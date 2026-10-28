# typed: true
class SubscriptionsController < ApplicationController
  before_action :set_user
  around_action :set_user_locale
  skip_authorization_check

  sig { void }
  def edit
  end

  sig { void }
  def update
    @user.update!(subscriptions_params)
    redirect_to edit_subscriptions_path(token: @user.subscriptions_token),
                notice: t("flash.actions.save_changes.notice")
  end

  private

    sig { void }
    def set_user
      @user = if params[:token].present?
                User.find_by!(subscriptions_token: params[:token])
              else
                current_user || raise(CanCan::AccessDenied)
              end
    end

    sig { returns(ActionController::Parameters) }
    def subscriptions_params
      params.require(:user).permit(allowed_params)
    end

    sig { returns(T::Array[T.untyped]) }
    def allowed_params
      [:email_on_comment, :email_on_comment_reply, :email_on_direct_message, :email_digest, :newsletter]
    end

    sig { params(action: T.proc.void).void }
    def set_user_locale(&action)
      if params[:locale].blank?
        session[:locale] = find_locale.to_s
      end
      I18n.with_locale(session[:locale], &action)
    end

    sig { returns(Symbol) }
    def find_locale
      Setting.enabled_locales.find { |locale| locale == @user.locale&.to_sym } || T.cast(I18n.locale, Symbol)
    end
end
