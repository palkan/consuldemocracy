# typed: true
class Admin::SettingsController < Admin::BaseController
  sig { void }
  def index
  end

  sig { void }
  def update
    @setting = Setting.find(params[:id])
    @setting.update!(settings_params)

    respond_to do |format|
      format.html { redirect_to request_referer, notice: t("admin.settings.flash.updated") }
      format.js
    end
  end

  sig { void }
  def update_map
    Setting["map.latitude"] = params[:map_location][:latitude].to_f
    Setting["map.longitude"] = params[:map_location][:longitude].to_f
    Setting["map.zoom"] = params[:map_location][:zoom].to_i
    redirect_to request_referer, notice: t("admin.settings.index.map.flash.update")
  end

  sig { void }
  def update_content_types
    setting = Setting.find(params[:id])
    group = T.must(setting.content_type_group)
    mime_type_values = content_type_params.keys.map do |content_type|
      T.must(Setting.mime_types[group])[content_type]
    end
    setting.update! value: mime_type_values.join(" ")
    redirect_to request_referer, notice: t("admin.settings.flash.updated")
  end

  private

    sig { returns(ActionController::Parameters) }
    def settings_params
      params.require(:setting).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      [:value]
    end

    sig { returns(ActionController::Parameters) }
    def content_type_params
      params.permit(:jpg, :png, :gif, :pdf, :doc, :docx, :xls, :xlsx, :csv, :zip)
    end

    sig { returns(String) }
    def request_referer
      request.referer + params[:tab].to_s
    end
end
