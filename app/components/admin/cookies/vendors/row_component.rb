# typed: strict
class Admin::Cookies::Vendors::RowComponent < ApplicationComponent
  with_collection_parameter :vendor

  sig { returns(::Cookies::Vendor) }
  attr_reader :vendor

  sig { params(vendor: ::Cookies::Vendor).void }
  def initialize(vendor:)
    @vendor = vendor
  end
end
