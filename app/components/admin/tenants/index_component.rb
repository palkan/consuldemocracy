# typed: strict
class Admin::Tenants::IndexComponent < ApplicationComponent
  include Header

  sig { returns(Tenant::PrivateRelation) }
  attr_reader :tenants

  sig { params(tenants: Tenant::PrivateRelation).void }
  def initialize(tenants)
    @tenants = tenants
  end

  sig { override.returns(String) }
  def title
    t("admin.menu.multitenancy")
  end

  private

    sig { params(attribute: Symbol).returns(String) }
    def attribute_name(attribute)
      Tenant.human_attribute_name(attribute)
    end
end
