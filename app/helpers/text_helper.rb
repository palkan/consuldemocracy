# typed: strict
module TextHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params(text: T.nilable(String)).returns(T.nilable(String)) }
  def first_paragraph(text)
    if text.blank?
      ""
    else
      text.strip.split("\n").first
    end
  end
end
