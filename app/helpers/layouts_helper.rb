# typed: strict
module LayoutsHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig do
    params(text: String, path: String, is_active: T::Boolean, options: T::Hash[Symbol, T.untyped])
      .returns(ActiveSupport::SafeBuffer)
  end
  def layout_menu_link_to(text, path, is_active, options)
    title = t("shared.go_to_page") + text

    if is_active
      tag.span(t("shared.you_are_in"), class: "show-for-sr") + " " +
        link_to(text, path, options.merge(class: "is-active", title: title))
    else
      link_to(text, path, options.merge(title: title))
    end
  end

  sig { returns(ActiveSupport::SafeBuffer) }
  def common_html_attributes
    render Layout::CommonHtmlAttributesComponent.new
  end
end
