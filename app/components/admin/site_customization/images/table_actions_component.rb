# typed: strict
class Admin::SiteCustomization::Images::TableActionsComponent < ApplicationComponent
  sig { returns(SiteCustomization::Image) }
  attr_reader :image

  sig { params(image: SiteCustomization::Image).void }
  def initialize(image)
    @image = image
  end
end
