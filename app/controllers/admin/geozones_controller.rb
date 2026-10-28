# typed: true
class Admin::GeozonesController < Admin::BaseController
  respond_to :html

  load_and_authorize_resource

  sig { void }
  def index
    @geozones = Geozone.order(Arel.sql("LOWER(name)"))
  end

  sig { void }
  def new
  end

  sig { void }
  def edit
  end

  sig { void }
  def create
    @geozone = Geozone.new(geozone_params)

    if @geozone.save
      redirect_to admin_geozones_path, notice: t("admin.geozones.create.notice")
    else
      render :new
    end
  end

  sig { void }
  def update
    if @geozone.update(geozone_params)
      redirect_to admin_geozones_path, notice: t("admin.geozones.update.notice")
    else
      render :edit
    end
  end

  sig { void }
  def destroy
    if @geozone.safe_to_destroy?
      @geozone.destroy!
      redirect_to admin_geozones_path, notice: t("admin.geozones.delete.success")
    else
      redirect_to admin_geozones_path, flash: { error: t("admin.geozones.delete.error") }
    end
  end

  private

    sig { returns(ActionController::Parameters) }
    def geozone_params
      params.require(:geozone).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      [:name, :external_code, :census_code, :html_map_coordinates, :geojson, :color]
    end
end
