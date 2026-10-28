# typed: strict
class Admin::SiteCustomization::InformationTexts::FormComponent < ApplicationComponent
  sig { returns(T::Array[T::Array[I18nContent]]) }
  attr_reader :contents

  delegate :site_customization_enable_translation?, to: :helpers

  sig { params(contents: T::Array[T::Array[I18nContent]]).void }
  def initialize(contents)
    @contents = contents
  end

  private

    sig { params(locale: T.any(String, Symbol), enabled: T.untyped).returns(ActiveSupport::SafeBuffer) }
    def translation_enabled_tag(locale, enabled)
      hidden_field_tag("enabled_translations[#{locale}]", (enabled ? 1 : 0))
    end

    sig { returns(T::Array[Symbol]) }
    def enabled_locales
      Setting.enabled_locales
    end
end
