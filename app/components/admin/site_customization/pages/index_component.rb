# typed: strict
class Admin::SiteCustomization::Pages::IndexComponent < ApplicationComponent
  include Header

  sig { returns(SiteCustomization::Page::PrivateRelation) }
  attr_reader :pages

  sig { params(pages: SiteCustomization::Page::PrivateRelation).void }
  def initialize(pages)
    @pages = pages
  end

  private

    sig { override.returns(String) }
    def title
      t("admin.site_customization.pages.index.title")
    end
end
