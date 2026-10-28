# typed: strict
class Admin::Cookies::Vendors::EditComponent < ApplicationComponent
  include Header

  sig { returns(::Cookies::Vendor) }
  attr_reader :vendor

  sig { params(vendor: ::Cookies::Vendor).void }
  def initialize(vendor)
    @vendor = vendor
  end

  private

    sig { override.returns(String) }
    def title
      t("admin.cookies.vendors.edit.title")
    end
end
