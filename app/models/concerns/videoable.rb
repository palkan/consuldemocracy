# typed: strict
module Videoable
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ApplicationRecord }

  included do
    validate :valid_video_url
  end

  sig { void }
  def valid_video_url
    errors.add(video_url_field, :invalid) unless valid_video_url?
  end

  sig { returns(T::Boolean) }
  def valid_video_url?
    video_url_value.blank? || video_url_parser.valid?
  end

  sig { returns(T.nilable(String)) }
  def embed_video_url
    video_url_parser.embed_url
  end

  sig { returns(Symbol) }
  def video_url_field
    if has_attribute?(:video_url)
      :video_url
    else
      :url
    end
  end

  sig { returns(T.nilable(String)) }
  def video_url_value
    send(video_url_field)
  end

  sig { returns(VideoUrlParser) }
  def video_url_parser
    VideoUrlParser.new(video_url_value)
  end
end
