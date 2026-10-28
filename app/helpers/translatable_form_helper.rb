# typed: strict
module TranslatableFormHelper
  extend T::Sig
  extend T::Helpers

  # Included in views and in components
  requires_ancestor { ActionView::Helpers }

  sig do
    params(
      record: T.untyped,
      options: T::Hash[Symbol, T.untyped],
      "&": T.proc.params(form: TranslatableFormBuilder).returns(T.untyped)
    ).returns(ActiveSupport::SafeBuffer)
  end
  def translatable_form_for(record, options = {}, &)
    form_for(record, options.merge(builder: TranslatableFormBuilder), &)
  end

  sig { returns(T::Boolean) }
  def translations_interface_enabled?
    Setting["feature.translation_interface"].present? || backend_translations_enabled?
  end

  sig { returns(T::Boolean) }
  def backend_translations_enabled?
    controller.class.module_parents.intersect?([Admin, Management, Valuation, SDGManagement])
  end

  sig { returns(T.nilable(String)) }
  def highlight_translation_html_class
    "highlight" if translations_interface_enabled?
  end
end
