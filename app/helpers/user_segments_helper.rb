# typed: strict
module UserSegmentsHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { returns(T::Array[[String, String]]) }
  def user_segments_options
    UserSegments.segments.map do |user_segment_name|
      [segment_name(user_segment_name), user_segment_name]
    end
  end

  sig { params(user_segment: T.nilable(T.any(String, Symbol))).returns(String) }
  def segment_name(user_segment)
    UserSegments.segment_name(user_segment) || I18n.t("admin.segment_recipient.invalid_recipients_segment")
  end
end
