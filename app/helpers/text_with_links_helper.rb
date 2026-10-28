# typed: strict
module TextWithLinksHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params(text: T.nilable(String)).returns(T.nilable(ActiveSupport::SafeBuffer)) }
  def sanitize_and_auto_link(text)
    return unless text

    sanitized = sanitize(text, tags: [], attributes: [])
    auto_link_already_sanitized_html(sanitized)
  end

  sig { params(html: T.nilable(ActiveSupport::SafeBuffer)).returns(T.nilable(ActiveSupport::SafeBuffer)) }
  def auto_link_already_sanitized_html(html)
    return if html.nil?
    raise "Could not add links because the content is not safe" unless html.html_safe?

    raw Rinku.auto_link(html, :all, 'rel="nofollow"')
  end
end
