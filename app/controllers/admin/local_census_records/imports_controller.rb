# typed: true
class Admin::LocalCensusRecords::ImportsController < Admin::LocalCensusRecords::BaseController
  load_and_authorize_resource class: "LocalCensusRecords::Import"

  sig { void }
  def create
    @import = LocalCensusRecords::Import.new(local_census_records_import_params)
    if @import.save
      flash.now[:notice] = t("admin.local_census_records.imports.create.notice")
      render :show
    else
      render :new
    end
  end

  private

    sig { returns(T.any(ActionController::Parameters, T::Hash[T.untyped, T.untyped])) }
    def local_census_records_import_params
      return {} if params[:local_census_records_import].blank?

      params.require(:local_census_records_import).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      [:file]
    end
end
