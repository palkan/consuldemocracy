# typed: strict
class Admin::Tenants::RowComponent < ApplicationComponent
  sig { returns(Tenant) }
  attr_reader :tenant

  sig { params(tenant: Tenant).void }
  def initialize(tenant)
    @tenant = tenant
  end
end
