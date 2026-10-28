# typed: strict
class Admin::Settings::CookiesConsentTabComponent < ApplicationComponent
  sig { returns(String) }
  def tab
    "#tab-cookies-consent"
  end
end
