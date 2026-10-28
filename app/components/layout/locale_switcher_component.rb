# typed: strict
class Layout::LocaleSwitcherComponent < ApplicationComponent
  delegate :name_for_locale, :link_list, :current_path_with_query_params, :rtl?, to: :helpers

  sig { returns(T::Boolean) }
  def render?
    locales.size > 1
  end

  private

    sig { returns(T::Boolean) }
    def many_locales?
      locales.size > 4
    end

    sig { returns(T::Array[Symbol]) }
    def locales
      Setting.enabled_locales
    end

    sig { returns(String) }
    def label
      t("layouts.header.locale")
    end

    sig { returns(String) }
    def label_id
      "locale_switcher_label"
    end

    sig { returns(T::Array[T::Array[T.untyped]]) }
    def language_links
      locales.map do |locale|
        [
          name_for_locale(locale),
          current_path_with_query_params(locale: locale),
          locale == I18n.locale,
          lang: locale,
          data: { turbolinks: rtl?(I18n.locale) == rtl?(locale) }
        ]
      end
    end

    sig { returns(T::Array[T::Array[T.untyped]]) }
    def language_options
      language_links.map do |text, path, _, options|
        [text, path, options]
      end
    end
end
