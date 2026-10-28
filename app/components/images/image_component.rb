# typed: strict
class Images::ImageComponent < ApplicationComponent
  sig { returns(Image) }
  attr_reader :image

  sig { returns(T.nilable(Symbol)) }
  attr_reader :version

  sig { returns(T::Boolean) }
  attr_reader :show_caption

  sig { params(image: Image, version: T.nilable(Symbol), show_caption: T::Boolean).void }
  def initialize(image, version, show_caption: true)
    @image = image
    @version = version
    @show_caption = show_caption
  end

  private

    sig { returns(String) }
    def image_class
      image.persisted? ? "persisted-image" : "cached-image"
    end
end
