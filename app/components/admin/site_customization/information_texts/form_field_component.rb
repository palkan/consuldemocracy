# typed: strict
class Admin::SiteCustomization::InformationTexts::FormFieldComponent < ApplicationComponent
  sig { returns(I18nContent) }
  attr_reader :i18n_content

  sig { returns(Symbol) }
  attr_reader :locale

  delegate :globalize, :site_customization_enable_translation?, to: :helpers

  sig { params(i18n_content: I18nContent, locale: Symbol).void }
  def initialize(i18n_content, locale:)
    @i18n_content = i18n_content
    @locale = locale
  end

  private

    sig { returns(T.untyped) }
    def text
      database_text || i18n_text
    end

    sig { returns(T.nilable(String)) }
    def database_text
      if i18n_content.persisted?
        i18n_content.translations.find_by(locale: locale)&.value
      end
    end

    sig { returns(T.untyped) }
    def i18n_text
      I18n.translate(i18n_key, locale: locale)
    end

    sig { returns(T.nilable(String)) }
    def i18n_key
      i18n_content.key
    end

    sig { returns(String) }
    def html_id
      html_name.tr("[", "_").tr("]", "")
    end

    sig { returns(String) }
    def html_name
      "contents[content_#{i18n_key}][values][value_#{locale}]"
    end

    sig { returns(String) }
    def display_style
      site_customization_enable_translation?(locale) ? "" : "display: none;"
    end
end
