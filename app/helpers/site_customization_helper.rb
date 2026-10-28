# typed: strict
module SiteCustomizationHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params(locale: T.any(String, Symbol)).returns(T::Boolean) }
  def site_customization_enable_translation?(locale)
    I18nContentTranslation.existing_locales.include?(locale) || locale == I18n.locale
  end

  sig { returns(T::Array[Symbol]) }
  def information_texts_tabs
    [:basic, :debates, :community, :proposals, :polls, :legislation, :budgets, :layouts, :mailers,
     :management, :welcome, :machine_learning]
  end
end
