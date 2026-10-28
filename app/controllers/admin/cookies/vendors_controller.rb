# typed: true
class Admin::Cookies::VendorsController < Admin::BaseController
  load_and_authorize_resource :vendor, class: "::Cookies::Vendor"

  sig { void }
  def create
    if @vendor.save
      redirect_to admin_settings_path(anchor: "tab-cookies-consent"),
                  notice: t("admin.cookies.vendors.create.notice")
    else
      render :new
    end
  end

  sig { void }
  def update
    if @vendor.update(vendor_params)
      redirect_to admin_settings_path(anchor: "tab-cookies-consent"),
                  notice: t("admin.cookies.vendors.update.notice")
    else
      render :edit
    end
  end

  sig { void }
  def destroy
    @vendor.destroy!

    redirect_to admin_settings_path(anchor: "tab-cookies-consent"),
                notice: t("admin.cookies.vendors.destroy.notice")
  end

  private

    sig { returns(ActionController::Parameters) }
    def vendor_params
      params.require(:cookies_vendor).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      [:name, :description, :cookie, :script]
    end
end
