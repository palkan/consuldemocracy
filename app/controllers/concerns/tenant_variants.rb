# typed: strict
module TenantVariants
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ActionController::Base }

  included do
    before_action :set_tenant_variant
  end

  private

    sig { void }
    def set_tenant_variant
      request.variant = Tenant.current_schema.to_sym
    end
end
