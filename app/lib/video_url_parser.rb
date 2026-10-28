# typed: strict
class VideoUrlParser
  extend T::Sig

  sig { returns(T.nilable(String)) }
  attr_reader :url

  VIMEO_REGEX = T.let(/vimeo.*(staffpicks\/|channels\/|videos\/|video\/|\/)([^#\&\?]*).*/, Regexp)
  YOUTUBE_REGEX = T.let(/youtu.*(be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/, Regexp)

  sig { params(url: T.nilable(String)).void }
  def initialize(url)
    @url = url
  end

  sig { returns(T::Boolean) }
  def valid?
    match.present?
  end

  sig { returns(T.nilable(String)) }
  def embed_url
    if VIMEO_REGEX.match?(url)
      "https://player.vimeo.com/video/#{url_id}?dnt=1"
    elsif YOUTUBE_REGEX.match?(url)
      "https://www.youtube-nocookie.com/embed/#{url_id}"
    end
  end

  private

    sig { returns(T.nilable(MatchData)) }
    def match
      VIMEO_REGEX.match(url) || YOUTUBE_REGEX.match(url)
    end

    sig { returns(T.nilable(String)) }
    def url_id
      matched = match
      matched[2] if matched
    end
end
