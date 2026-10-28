# typed: strict
class Admin::Tenants::NewComponent < ApplicationComponent
  include Header

  sig { returns(Tenant) }
  attr_reader :tenant

  sig { params(tenant: Tenant).void }
  def initialize(tenant)
    @tenant = tenant
  end

  sig { override.returns(String) }
  def title
    t("admin.tenants.new.title")
  end
end
