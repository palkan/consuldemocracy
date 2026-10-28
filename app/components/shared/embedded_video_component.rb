# typed: strict
class Shared::EmbeddedVideoComponent < ApplicationComponent
  sig { returns(T.untyped) }
  attr_reader :record

  sig { params(record: T.untyped).void }
  def initialize(record)
    @record = record
  end

  sig { returns(T::Boolean) }
  def render?
    embed_url.present?
  end

  sig { returns(String) }
  def embedded_video_code
    "<iframe #{iframe_attributes}></iframe>"
  end

  sig { returns(T.nilable(String)) }
  def consent_required?
    feature?("gdpr.require_consent_for_embedded_videos")
  end

  private

    sig { returns(String) }
    def title
      t("proposals.show.embed_video_title", proposal: record.title)
    end

    sig { returns(T.nilable(String)) }
    def embed_url
      record.embed_video_url
    end

    sig { returns(ActiveSupport::SafeBuffer) }
    def iframe_attributes
      tag.attributes(src: embed_url, style: "border:0;", allowfullscreen: true, title: title)
    end
end
