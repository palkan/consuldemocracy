# typed: strict
class Admin::Cookies::Vendors::NewComponent < ApplicationComponent
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
      t("admin.cookies.vendors.new.title")
    end
end
