# typed: strict
module StatsHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params(number: T.nilable(Numeric), options: T::Hash[Symbol, T.untyped]).returns(T.nilable(String)) }
  def number_to_stats_percentage(number, options = {})
    number_to_percentage(number, { strip_insignificant_zeros: true, precision: 2 }.merge(options))
  end

  sig { params(number: T.untyped, text: String, html_class: String).returns(ActiveSupport::SafeBuffer) }
  def number_with_info_tags(number, text, html_class: "")
    tag.p class: "number-with-info #{html_class}".strip do
      tag.span class: "content" do
        tag.span(number, class: "number") + tag.span(text, class: "info")
      end
    end
  end
end
