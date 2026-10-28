# typed: true
class Admin::SignatureSheetsController < Admin::BaseController
  sig { void }
  def index
    @signature_sheets = SignatureSheet.order(created_at: :desc)
  end

  sig { void }
  def new
    @signature_sheet = SignatureSheet.new
  end

  sig { void }
  def create
    @signature_sheet = SignatureSheet.new(signature_sheet_params)
    @signature_sheet.author = current_user
    if @signature_sheet.save
      @signature_sheet.delay.verify_signatures
      redirect_to [:admin, @signature_sheet], notice: I18n.t("flash.actions.create.signature_sheet")
    else
      render :new
    end
  end

  sig { void }
  def show
    @signature_sheet = SignatureSheet.find(params[:id])
  end

  private

    sig { returns(ActionController::Parameters) }
    def signature_sheet_params
      params.require(:signature_sheet).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      [:signable_type, :signable_id, :title, :required_fields_to_verify]
    end
end
