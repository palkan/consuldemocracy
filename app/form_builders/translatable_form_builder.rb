# typed: true
class TranslatableFormBuilder < ConsulFormBuilder
  # Translations of the object (one per locale), which are records of the object's translation class
  sig { returns(T.nilable(T::Hash[Symbol, T.untyped])) }
  attr_accessor :translations

  sig do
    params("&": T.proc.params(translations_form: TranslationsFieldsFormBuilder).returns(T.untyped))
      .returns(ActiveSupport::SafeBuffer)
  end
  def translatable_fields(&)
    @translations = {}
    visible_locales.map do |locale|
      @translations[locale] = translation_for(locale)
    end
    safe_join(visible_locales.map do |locale|
      Globalize.with_locale(locale) { fields_for_locale(locale, &) }
    end)
  end

  private

    sig do
      params(
        locale: Symbol,
        "&": T.proc.params(translations_form: TranslationsFieldsFormBuilder).returns(T.untyped)
      ).returns(ActiveSupport::SafeBuffer)
    end
    def fields_for_locale(locale, &)
      fields_for_translation(T.must(@translations)[locale]) do |translations_form|
        @template.tag.div(**translations_options(translations_form.object, locale)) do
          @template.concat translations_form.hidden_field(
            :_destroy,
            value: !@template.enabled_locale?(translations_form.object.globalized_model, locale),
            data: { locale: locale }
          )

          @template.concat translations_form.hidden_field(:locale, value: locale)

          yield translations_form
        end
      end
    end

    sig do
      params(
        translation: T.untyped,
        "&": T.proc.params(translations_form: TranslationsFieldsFormBuilder).returns(T.untyped)
      ).returns(ActiveSupport::SafeBuffer)
    end
    def fields_for_translation(translation, &)
      fields_for(:translations, translation, builder: TranslationsFieldsFormBuilder, &)
    end

    sig { params(locale: Symbol).returns(T.untyped) }
    def translation_for(locale)
      existing_translation_for(locale) || new_translation_for(locale)
    end

    sig { params(locale: Symbol).returns(T.untyped) }
    def existing_translation_for(locale)
      @object.translations.find { |translation| translation.locale == locale }
    end

    sig { params(locale: Symbol).returns(T.untyped) }
    def new_translation_for(locale)
      @object.translations.new(locale: locale).tap(&:mark_for_destruction)
    end

    sig { returns(T.nilable(String)) }
    def highlight_translation_html_class
      @template.highlight_translation_html_class
    end

    sig { params(resource: T.untyped, locale: Symbol).returns(T::Hash[Symbol, T.untyped]) }
    def translations_options(resource, locale)
      {
        class: "translatable-fields js-globalize-attribute #{highlight_translation_html_class}",
        style: @template.display_translation_style(resource.globalized_model, locale),
        data: { locale: locale }
      }
    end

    sig { params(translation: T.untyped).returns(T::Boolean) }
    def no_other_translations?(translation)
      (@object.translations - [translation]).reject(&:_destroy).empty?
    end

    sig { returns(T::Array[Symbol]) }
    def visible_locales
      if @template.translations_interface_enabled?
        Setting.enabled_locales & @object.globalize_locales
      else
        [T.cast(I18n.locale, Symbol)]
      end
    end
end
