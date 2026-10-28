# typed: strict
class Admin::Banners::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  sig { returns(Banner) }
  attr_reader :banner

  sig { params(banner: Banner).void }
  def initialize(banner)
    @banner = banner
  end

  private

    sig { returns(WebSection::PrivateRelation) }
    def sections
      WebSection.all
    end
end
