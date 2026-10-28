# typed: true
class Admin::LocalesController < Admin::BaseController
  before_action :set_locales_settings
  authorize_resource instance_name: :locales_settings, class: "Setting::LocalesSettings"

  sig { void }
  def show
  end

  sig { void }
  def update
    @locales_settings.update!(locales_settings_params)

    redirect_to admin_locales_path, notice: t("admin.locales.update.notice")
  end

  private

    sig { returns(ActionController::Parameters) }
    def locales_settings_params
      params.require(:setting_locales_settings).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      [:default, enabled: []]
    end

    sig { void }
    def set_locales_settings
      @locales_settings = Setting::LocalesSettings.new
    end
end
