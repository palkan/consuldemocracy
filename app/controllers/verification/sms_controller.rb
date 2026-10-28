# typed: true
class Verification::SmsController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_resident!
  before_action :verify_verified!
  before_action :verify_lock, only: [:new, :create]
  before_action :set_phone, only: :create

  skip_authorization_check

  sig { void }
  def new
    @sms = Verification::Sms.new(phone: params[:phone])
  end

  sig { void }
  def create
    @sms = Verification::Sms.new(phone: @phone, user: current_user)
    if @sms.save
      redirect_to edit_sms_path, notice: t("verification.sms.create.flash.success")
    else
      render :new
    end
  end

  sig { void }
  def edit
    @sms = Verification::Sms.new
  end

  sig { void }
  def update
    @sms = Verification::Sms.new(sms_params.merge(user: current_user))
    if @sms.verified?
      T.must(current_user).update!(confirmed_phone: T.must(current_user).unconfirmed_phone)

      if VerifiedUser.phone?(T.must(current_user))
        T.must(current_user).update(verified_at: Time.current)
      end

      redirect_to_next_path
    else
      @error = t("verification.sms.update.error")
      render :edit
    end
  end

  private

    sig { returns(ActionController::Parameters) }
    def sms_params
      params.require(:sms).permit(allowed_params)
    end

    sig { returns(T::Array[T.untyped]) }
    def allowed_params
      [:phone, :confirmation_code]
    end

    sig { void }
    def set_phone
      if verified_user
        @phone = @verified_user.phone
      else
        @phone = sms_params[:phone]
      end
    end

    sig { returns(T.nilable(T.any(VerifiedUser, FalseClass))) }
    def verified_user
      return false unless params[:verified_user]

      @verified_user = VerifiedUser.by_user(current_user).find_by(id: params[:verified_user][:id])
    end

    sig { void }
    def redirect_to_next_path
      T.must(current_user).reload
      if T.must(current_user).level_three_verified?
        redirect_to account_path, notice: t("verification.sms.update.flash.level_three.success")
      else
        redirect_to new_letter_path, notice: t("verification.sms.update.flash.level_two.success")
      end
    end
end
