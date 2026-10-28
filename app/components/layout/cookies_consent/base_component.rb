# typed: strict
class Layout::CookiesConsent::BaseComponent < ApplicationComponent
  sig { returns(T.nilable(T.any(String, T::Boolean))) }
  def render?
    feature?(:cookies_consent)
  end

  sig { returns(T.nilable(String)) }
  def more_info_link
    Setting["cookies_consent.more_info_link"]
  end

  sig { returns(Cookies::Vendor::PrivateRelation) }
  def vendors
    Cookies::Vendor.all
  end

  sig { returns(String) }
  def version_name
    Setting["cookies_consent.version_name"].to_s.strip
  end
end
