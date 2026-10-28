# typed: true
class Verification::LetterController < ApplicationController
  before_action :authenticate_user!, except: [:edit, :update]
  before_action :login_via_form, only: :update

  before_action :verify_resident!, if: :signed_in?
  before_action :verify_phone!, if: :signed_in?
  before_action :verify_verified!, if: :signed_in?
  before_action :verify_lock, if: :signed_in?

  skip_authorization_check

  sig { void }
  def new
    @letter = Verification::Letter.new(user: current_user)
  end

  sig { void }
  def create
    @letter = Verification::Letter.new(user: current_user)
    @letter.save!
    redirect_to letter_path
  end

  sig { void }
  def show
  end

  sig { void }
  def edit
    @letter = Verification::Letter.new
  end

  sig { void }
  def update
    @letter = Verification::Letter.new(letter_params.merge(user: current_user, verify: true))
    if @letter.valid?
      T.must(current_user).update!(verified_at: Time.current)
      redirect_to account_path, notice: t("verification.letter.update.flash.success")
    else
      Lock.increase_tries(@letter.user) if @letter.user
      render :edit
    end
  end

  private

    sig { returns(ActionController::Parameters) }
    def letter_params
      params.require(:verification_letter).permit(allowed_params)
    end

    sig { returns(T::Array[T.untyped]) }
    def allowed_params
      [:verification_code, :email, :password]
    end

    sig { void }
    def verify_phone!
      unless T.must(current_user).sms_verified?
        redirect_to verified_user_path, alert: t("verification.letter.alert.unconfirmed_code")
      end
    end

    sig { void }
    def login_via_form
      user = User.find_by email: letter_params[:email]
      if user&.valid_password?(letter_params[:password])
        sign_in(user)
      end
    end
end
