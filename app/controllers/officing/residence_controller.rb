# typed: true
class Officing::ResidenceController < Officing::BaseController
  before_action :load_officer_assignment
  before_action :verify_officer_assignment
  before_action :verify_booth

  sig { void }
  def new
    @residence = Officing::Residence.new
  end

  sig { void }
  def create
    @residence = Officing::Residence.new(residence_params.merge(officer: T.must(current_user).poll_officer))
    if @residence.save
      redirect_to new_officing_voter_path(id: T.must(@residence.user).id),
                  notice: t("officing.residence.flash.create")
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
      [:document_number, :document_type, :year_of_birth, :date_of_birth, :postal_code]
    end
end
