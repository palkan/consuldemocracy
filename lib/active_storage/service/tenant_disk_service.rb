# typed: strict
require "active_storage/service/disk_service"

module ActiveStorage
  class Service::TenantDiskService < Service::DiskService
    extend T::Sig

    sig { returns(String) }
    def tenant_root
      File.join(root, Tenant.subfolder_path)
    end

    sig { params(schema: String).returns(String) }
    def tenant_root_for(schema)
      File.join(root, Tenant.subfolder_path_for(schema))
    end

    sig { params(key: String).returns(String) }
    def path_for(key)
      if Tenant.default?
        super
      else
        super.sub(root, tenant_root)
      end
    end
  end
end
