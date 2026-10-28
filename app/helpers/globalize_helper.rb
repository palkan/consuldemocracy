# typed: strict
module GlobalizeHelper
  extend T::Sig
  extend T::Helpers

  # Included in views and in components
  requires_ancestor { ActionView::Helpers }

  sig { params(resource: T.nilable(Globalizable), locale: T.any(String, Symbol)).returns(T::Boolean) }
  def enabled_locale?(resource, locale)
    return site_customization_enable_translation?(locale) if resource.blank?

    if resource.locales_not_marked_for_destruction.any?
      resource.locales_not_marked_for_destruction.include?(locale)
    elsif resource.locales_persisted_and_marked_for_destruction.any?
      locale == first_marked_for_destruction_translation(resource)
    else
      locale == I18n.locale
    end
  end

  sig { params(resource: Globalizable).returns(T.nilable(T.any(Symbol, String))) }
  def first_translation(resource)
    if resource.locales_not_marked_for_destruction.include? I18n.locale
      T.cast(I18n.locale, Symbol)
    else
      resource.locales_not_marked_for_destruction.first
    end
  end

  sig { params(resource: Globalizable).returns(T.nilable(T.any(Symbol, String))) }
  def first_marked_for_destruction_translation(resource)
    if resource.locales_persisted_and_marked_for_destruction.include? I18n.locale
      T.cast(I18n.locale, Symbol)
    else
      resource.locales_persisted_and_marked_for_destruction.first
    end
  end

  sig { params(resource: T.nilable(Globalizable), locale: T.any(String, Symbol)).returns(T.nilable(String)) }
  def display_translation_style(resource, locale)
    "display: none;" unless display_translation?(resource, locale)
  end

  sig { params(resource: T.nilable(Globalizable), locale: T.any(String, Symbol)).returns(T::Boolean) }
  def display_translation?(resource, locale)
    return locale == I18n.locale if resource.blank?

    if resource.locales_not_marked_for_destruction.any?
      locale == first_translation(resource)
    elsif resource.locales_persisted_and_marked_for_destruction.any?
      locale == first_marked_for_destruction_translation(resource)
    else
      locale == I18n.locale
    end
  end

  sig { params(locale: T.any(String, Symbol), "&": T.proc.returns(T.untyped)).returns(T.untyped) }
  def globalize(locale, &)
    Globalize.with_locale(locale, &)
  end
end
