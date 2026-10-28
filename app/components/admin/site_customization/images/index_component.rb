# typed: strict
class Admin::SiteCustomization::Images::IndexComponent < ApplicationComponent
  include Header

  sig { returns(T::Array[SiteCustomization::Image]) }
  attr_reader :images

  sig { params(images: T::Array[SiteCustomization::Image]).void }
  def initialize(images)
    @images = images
  end

  private

    sig { override.returns(String) }
    def title
      t("admin.site_customization.images.index.title")
    end

    sig { params(image: SiteCustomization::Image).returns(ActiveSupport::SafeBuffer) }
    def image_description(image)
      safe_join([
        tag.strong(image.name),
        tag.span(image_hint(image), id: dom_id(image, :hint))
      ], " ")
    end

    sig { params(image: SiteCustomization::Image).returns(String) }
    def image_hint(image)
      t("admin.site_customization.images.index.dimensions",
        width: image.required_width,
        height: image.required_height)
    end
end
