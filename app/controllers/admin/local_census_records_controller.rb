# typed: true
class Admin::LocalCensusRecordsController < Admin::BaseController
  load_and_authorize_resource class: "LocalCensusRecord"

  sig { void }
  def index
    @local_census_records = @local_census_records.search(params[:search])
    @local_census_records = @local_census_records.page(params[:page])
  end

  sig { void }
  def create
    @local_census_record = LocalCensusRecord.new(local_census_record_params)
    if @local_census_record.save
      redirect_to admin_local_census_records_path,
                  notice: t("admin.local_census_records.create.notice")
    else
      render :new
    end
  end

  sig { void }
  def update
    if @local_census_record.update(local_census_record_params)
      redirect_to admin_local_census_records_path,
                  notice: t("admin.local_census_records.update.notice")
    else
      render :edit
    end
  end

  sig { void }
  def destroy
    @local_census_record.destroy!
    redirect_to admin_local_census_records_path,
                notice: t("admin.local_census_records.destroy.notice")
  end

  private

    sig { returns(ActionController::Parameters) }
    def local_census_record_params
      params.require(:local_census_record).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      [:document_type, :document_number, :date_of_birth, :postal_code]
    end
end
