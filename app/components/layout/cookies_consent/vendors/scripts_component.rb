# typed: strict
class Layout::CookiesConsent::Vendors::ScriptsComponent < Layout::CookiesConsent::BaseComponent
  sig { returns(T.nilable(T::Boolean)) }
  def render?
    super && vendors.any?
  end
end
