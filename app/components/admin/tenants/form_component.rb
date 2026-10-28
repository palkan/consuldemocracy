# typed: strict
class Admin::Tenants::FormComponent < ApplicationComponent
  sig { returns(Tenant) }
  attr_reader :tenant

  sig { params(tenant: Tenant).void }
  def initialize(tenant)
    @tenant = tenant
  end

  private

    sig { params(attribute: T.any(String, Symbol)).returns(String) }
    def attribute_name(attribute)
      Tenant.human_attribute_name(attribute)
    end

    sig { returns(T.nilable(String)) }
    def domain
      Tenant.default_domain
    end

    sig { returns(T::Hash[Symbol, String]) }
    def schema_labels_per_schema_type
      Tenant.schema_types.keys.to_h do |schema_type|
        [:"schema_type_#{schema_type}", attribute_name(schema_type)]
      end
    end
end
