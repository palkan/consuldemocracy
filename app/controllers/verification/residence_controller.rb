# typed: true
class Verification::ResidenceController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_verified!
  before_action :verify_lock, only: [:new, :create]
  skip_authorization_check

  sig { void }
  def new
    @residence = Verification::Residence.new
  end

  sig { void }
  def create
    @residence = Verification::Residence.new(residence_params.merge(user: current_user))
    if @residence.save
      redirect_to verified_user_path, notice: t("verification.residence.create.flash.success")
    else
      render :new
    end
  end

  private

    sig { returns(ActionController::Parameters) }
    def residence_params
      params.require(:residence).permit(allowed_params)
    end

    sig { returns(T::Array[T.untyped]) }
    def allowed_params
      [:document_number, :document_type, :date_of_birth, :postal_code, :terms_of_service]
    end
end
