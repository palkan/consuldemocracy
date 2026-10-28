# typed: true
class Verification::EmailController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_verified!
  before_action :set_verified_user, only: :create
  skip_authorization_check

  sig { void }
  def show
    if Verification::Email.valid_token?(T.must(current_user), params[:email_verification_token])
      T.must(current_user).update!(verified_at: Time.current)
      redirect_to account_path, notice: t("verification.email.show.flash.success")
    else
      redirect_to verified_user_path, alert: t("verification.email.show.alert.failure")
    end
  end

  sig { void }
  def create
    @email = Verification::Email.new(@verified_user)
    if @email.save
      T.must(current_user).reload
      Mailer.email_verification(current_user,
                                @email.recipient,
                                @email.encrypted_token,
                                @verified_user.document_type,
                                @verified_user.document_number).deliver_later
      redirect_to account_path,
                  notice: t("verification.email.create.flash.success", email: @verified_user.email)
    else
      redirect_to verified_user_path, alert: t("verification.email.create.alert.failure")
    end
  end

  private

    sig { void }
    def set_verified_user
      @verified_user = VerifiedUser.by_user(current_user).find_by(id: verified_user_params[:id])
    end

    sig { returns(ActionController::Parameters) }
    def verified_user_params
      params.require(:verified_user).permit(:id)
    end
end
