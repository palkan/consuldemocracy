# typed: strict
class Pages::Help::SectionComponent < ApplicationComponent
  sig { returns(String) }
  attr_reader :section

  sig { params(section: String).void }
  def initialize(section)
    @section = section
  end

  sig { returns(T.nilable(String)) }
  def image_path
    locale_with_image = Array(I18n.fallbacks[I18n.locale]).find do |locale|
      AssetFinder.find_asset("help/#{section}_#{locale}.png")
    end

    if locale_with_image
      "help/#{section}_#{locale_with_image}.png"
    elsif AssetFinder.find_asset("help/#{section}.png")
      "help/#{section}.png"
    end
  end
end
