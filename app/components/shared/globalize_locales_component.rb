# typed: strict
class Shared::GlobalizeLocalesComponent < ApplicationComponent
  Locale = T.type_alias { T.nilable(T.any(Symbol, String, FalseClass)) }

  sig { returns(T.untyped) }
  attr_reader :resource

  sig { returns(T::Boolean) }
  attr_reader :manage_languages

  delegate :first_translation, :first_marked_for_destruction_translation,
           :enabled_locale?, :name_for_locale, :highlight_translation_html_class, to: :helpers

  sig { params(resource: T.untyped, manage_languages: T::Boolean).void }
  def initialize(resource = nil, manage_languages: true)
    @resource = resource
    @manage_languages = manage_languages
  end

  private

    sig { returns(ActiveSupport::SafeBuffer) }
    def options_for_select_language
      options_for_select(available_locales, selected_locale)
    end

    sig { returns(T::Array[T::Array[T.untyped]]) }
    def available_locales
      Setting.enabled_locales.select { |locale| enabled_locale?(resource, locale) }.map do |locale|
        [name_for_locale(locale), locale, { data: { locale: locale }}]
      end
    end

    sig { returns(Locale) }
    def selected_locale
      return first_i18n_content_locale if resource.blank?

      if resource.locales_not_marked_for_destruction.any?
        first_translation(resource)
      elsif resource.locales_persisted_and_marked_for_destruction.any?
        first_marked_for_destruction_translation(resource)
      else
        I18n.locale
      end
    end

    sig { returns(Locale) }
    def first_i18n_content_locale
      if i18n_content_locales.empty? || i18n_content_locales.include?(I18n.locale)
        I18n.locale
      else
        i18n_content_locales.first
      end
    end

    sig { returns(T.nilable(ActiveSupport::SafeBuffer)) }
    def selected_languages_description
      sanitize(t("shared.translations.languages_in_use", count: active_locales_count))
    end

    sig { returns(T.nilable(ActiveSupport::SafeBuffer)) }
    def select_language_error
      if select_language_error?
        tag.div class: "small error", id: "select_language_error" do
          resource.translation_for(selected_locale).errors[:base].join(", ")
        end
      end
    end

    sig { returns(T.nilable(T::Boolean)) }
    def select_language_error?
      return if resource.blank?

      current_translation = resource.translation_for(selected_locale)
      current_translation.errors.added? :base, :translations_too_short
    end

    sig { returns(T::Hash[T.any(String, Symbol), T.untyped]) }
    def select_language_html_options
      { class: "js-select-language" }.merge(select_language_error_html_options)
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def select_language_error_html_options
      if select_language_error?
        { "aria-invalid" => true, "aria-errormessage" => "select_language_error" }
      else
        {}
      end
    end

    sig { returns(Integer) }
    def active_locales_count
      if active_locales.size > 0
        active_locales.size
      else
        1
      end
    end

    sig { returns(T::Array[Symbol]) }
    def active_locales
      if resource.present?
        resource.locales_not_marked_for_destruction
      else
        i18n_content_locales
      end
    end

    sig { params(locale: Symbol).returns(T.nilable(String)) }
    def display_destroy_locale_style(locale)
      "display: none;" unless display_destroy_locale_link?(locale)
    end

    sig { params(locale: Symbol).returns(T::Boolean) }
    def display_destroy_locale_link?(locale)
      selected_locale == locale
    end

    sig { returns(ActiveSupport::SafeBuffer) }
    def options_for_add_language
      options_for_select(all_language_options, nil)
    end

    sig { returns(T::Array[[String, Symbol]]) }
    def all_language_options
      Setting.enabled_locales.map do |locale|
        [name_for_locale(locale), locale]
      end
    end

    sig { returns(T::Array[Symbol]) }
    def i18n_content_locales
      I18nContentTranslation.existing_locales
    end
end
