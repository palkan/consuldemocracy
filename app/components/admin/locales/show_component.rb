# typed: strict
class Admin::Locales::ShowComponent < ApplicationComponent
  include Header

  sig { returns(Setting::LocalesSettings) }
  attr_reader :locales_settings

  sig { params(locales_settings: Setting::LocalesSettings).void }
  def initialize(locales_settings)
    @locales_settings = locales_settings
  end

  sig { override.returns(String) }
  def title
    t("admin.menu.locales")
  end
end
