# typed: strict
class Admin::Tenants::ToggleHiddenComponent < ApplicationComponent
  sig { returns(Tenant) }
  attr_reader :tenant

  sig { params(tenant: Tenant).void }
  def initialize(tenant)
    @tenant = tenant
  end

  private

    sig { returns(Symbol) }
    def action
      if enabled?
        :hide
      else
        :restore
      end
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def options
      {
        method: :put,
        "aria-label": t("admin.tenants.index.enable", tenant: tenant.name)
      }
    end

    sig { returns(T::Boolean) }
    def enabled?
      !tenant.hidden?
    end
end
