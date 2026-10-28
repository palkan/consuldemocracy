# typed: strict
class Admin::SiteCustomization::Pages::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  sig { returns(SiteCustomization::Page) }
  attr_reader :page

  sig { params(page: SiteCustomization::Page).void }
  def initialize(page)
    @page = page
  end

  private

    sig { params(attribute: Symbol).returns(String) }
    def attribute_name(attribute)
      SiteCustomization::Page.human_attribute_name(attribute)
    end
end
