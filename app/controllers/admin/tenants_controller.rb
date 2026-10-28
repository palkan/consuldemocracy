# typed: true
class Admin::TenantsController < Admin::BaseController
  load_and_authorize_resource

  sig { void }
  def index
    @tenants = @tenants.order(:name)
  end

  sig { void }
  def new
  end

  sig { void }
  def edit
  end

  sig { void }
  def create
    if @tenant.save
      update_default_tenant_administrator
      redirect_to admin_tenants_path, notice: t("admin.tenants.create.notice")
    else
      render :new
    end
  end

  sig { void }
  def update
    if @tenant.update(tenant_params)
      redirect_to admin_tenants_path, notice: t("admin.tenants.update.notice")
    else
      render :edit
    end
  end

  sig { void }
  def hide
    @tenant.hide

    respond_to do |format|
      format.html { redirect_to admin_tenants_path, notice: t("admin.tenants.hide.notice") }
      format.js { render template: "admin/tenants/toggle_enabled" }
    end
  end

  sig { void }
  def restore
    @tenant.restore

    respond_to do |format|
      format.html { redirect_to admin_tenants_path, notice: t("admin.tenants.restore.notice") }
      format.js { render template: "admin/tenants/toggle_enabled" }
    end
  end

  private

    sig { returns(ActionController::Parameters) }
    def tenant_params
      params.require(:tenant).permit(:name, :schema, :schema_type)
    end

    sig { void }
    def update_default_tenant_administrator
      user = T.must(current_user)
      tenant_administrator_credentials = {
        email: user.email,
        username: user.username,
        encrypted_password: user.encrypted_password
      }

      Tenant.switch(@tenant.schema) do
        default_admin_account = T.must(User.administrators.first)
        default_admin_account.skip_confirmation_notification!
        default_admin_account.update!(tenant_administrator_credentials)
        default_admin_account.confirm
      end
    end
end
