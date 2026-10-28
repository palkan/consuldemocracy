# typed: strict
class Admin::Cookies::Vendors::TableComponent < ApplicationComponent
  private

    sig { returns(::Cookies::Vendor::PrivateRelation) }
    def vendors
      ::Cookies::Vendor.all
    end

    sig { params(attribute: Symbol).returns(String) }
    def attribute_name(attribute)
      ::Cookies::Vendor.human_attribute_name(attribute)
    end
end
