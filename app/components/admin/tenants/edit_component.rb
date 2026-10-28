# typed: strict
class Admin::Tenants::EditComponent < ApplicationComponent
  include Header

  sig { returns(Tenant) }
  attr_reader :tenant

  sig { params(tenant: Tenant).void }
  def initialize(tenant)
    @tenant = tenant
  end

  sig { override.returns(T.nilable(String)) }
  def title
    tenant.name
  end
end
