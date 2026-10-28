# typed: strict
require "open-uri"

module ImageSuggestions
  class Pexels
    extend T::Sig

    class PexelsError < StandardError; end
    IMAGE_VARIANT_POSTFIX = T.let("?auto=compress&cs=tinysrgb&h=900".freeze, String)

    sig { params(query: String, "**": T.untyped).returns(T.untyped) }
    def self.search(query, **)
      new.search(query, **)
    end

    sig { params(photo_id: T.any(String, Integer)).returns(ActionDispatch::Http::UploadedFile) }
    def self.download(photo_id)
      new.download(photo_id)
    end

    sig { void }
    def initialize
      @client = T.let(::Pexels::Client.new(Tenant.current_secrets.pexels_access_key), T.untyped)
    end

    sig { params(query: String, "**": T.untyped).returns(T.untyped) }
    def search(query, **)
      @client.photos.search(query, **)
    end

    sig { params(photo_id: T.any(String, Integer)).returns(ActionDispatch::Http::UploadedFile) }
    def download(photo_id)
      photo = get_photo(photo_id)

      image_url = photo.src["original"] + IMAGE_VARIANT_POSTFIX
      temp_file = download_file(image_url)

      ActionDispatch::Http::UploadedFile.new(
        tempfile: temp_file,
        filename: I18n.t("images.form.suggested_image_filename", author_name: photo.user.name),
        type: "image/jpeg"
      )
    end

    private

      sig { params(photo_id: T.any(String, Integer)).returns(T.untyped) }
      def get_photo(photo_id)
        @client.photos.find(photo_id)
      end

      sig { params(image_url: String).returns(T.any(StringIO, Tempfile)) }
      def download_file(image_url)
        T.cast(URI.parse(image_url).open("rb"), T.any(StringIO, Tempfile))
      rescue OpenURI::HTTPError, SocketError => e
        raise PexelsError, "Failed to download image from Pexels: #{e.message}"
      end
  end
end
