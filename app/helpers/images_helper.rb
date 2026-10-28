# typed: strict
module ImagesHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params(image: T.nilable(Image), version: Symbol).returns(String) }
  def image_absolute_url(image, version)
    return "" unless image

    polymorphic_url(image.variant(version))
  end

  sig { params(image: Image, version: Symbol, show_caption: T::Boolean).returns(ActiveSupport::SafeBuffer) }
  def render_image(image, version, show_caption = true)
    render Images::ImageComponent.new(image, (version if image.persisted?), show_caption: show_caption)
  end

  sig { params(path: String).returns(String) }
  def attached_background_css(path)
    "background-image: url('#{j path}');"
  end
end
