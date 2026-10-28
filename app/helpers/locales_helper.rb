# typed: strict
module LocalesHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params(locale: T.any(String, Symbol)).returns(String) }
  def name_for_locale(locale)
    I18n.t("i18n.language.name", locale: locale, fallback: false, default: locale.to_s)
  end
end
