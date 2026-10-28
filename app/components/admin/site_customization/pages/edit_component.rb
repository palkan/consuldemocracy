# typed: strict
class Admin::SiteCustomization::Pages::EditComponent < ApplicationComponent
  include Header

  sig { returns(SiteCustomization::Page) }
  attr_reader :page

  sig { params(page: SiteCustomization::Page).void }
  def initialize(page)
    @page = page
  end

  sig { override.returns(String) }
  def title
    t("admin.site_customization.pages.edit.title", page_title: page.title)
  end
end
