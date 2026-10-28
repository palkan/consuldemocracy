# typed: strict
class Layout::CookiesConsent::VendorsComponent < Layout::CookiesConsent::BaseComponent
  delegate :cookies, :dom_id, to: :helpers

  sig { returns(T.nilable(T::Boolean)) }
  def render?
    super && vendors.any?
  end

  sig { params(vendor: Cookies::Vendor).returns(T::Boolean) }
  def enabled?(vendor)
    cookies[vendor.cookie] == "true"
  end
end
