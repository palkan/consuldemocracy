# typed: strict
class Admin::Locales::FormComponent < ApplicationComponent
  sig { returns(Setting::LocalesSettings) }
  attr_reader :locales_settings

  delegate :name_for_locale, to: :helpers

  sig { params(locales_settings: Setting::LocalesSettings).void }
  def initialize(locales_settings)
    @locales_settings = locales_settings
  end

  private

    sig { returns(T::Array[T.any(String, Symbol)]) }
    def available_locales
      I18n.available_locales
    end

    sig { returns(T::Boolean) }
    def many_available_locales?
      available_locales.count > select_field_threshold
    end

    sig { returns(T::Array[[T.untyped, T.any(String, Symbol)]]) }
    def locales_options
      available_locales.map { |locale| [name_for_locale(locale), locale] }
    end

    sig { returns(Integer) }
    def select_field_threshold
      10
    end

    sig { params(attribute: Symbol, options: T.untyped).returns(String) }
    def attribute_name(attribute, options = {})
      locales_settings.class.human_attribute_name(attribute, options)
    end
end
