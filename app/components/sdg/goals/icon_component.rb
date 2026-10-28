# typed: strict
class SDG::Goals::IconComponent < ApplicationComponent
  sig { returns(SDG::Goal) }
  attr_reader :goal

  delegate :code, to: :goal

  sig { params(goal: SDG::Goal).void }
  def initialize(goal)
    @goal = goal
    @locale = T.let(nil, T.nilable(T.any(String, Symbol)))
  end

  sig { returns(String) }
  def image_path
    if svg_available?
      svg_path(locale)
    else
      png_path(locale)
    end
  end

  private

    sig { returns(String) }
    def image_text
      goal.code_and_title
    end

    sig { returns(T.nilable(T.any(String, Symbol))) }
    def locale
      @locale ||= [*I18n.fallbacks[I18n.locale], "default"].find do |fallback|
        AssetFinder.find_asset(svg_path(fallback)) ||
          AssetFinder.find_asset(png_path(fallback))
      end
    end

    sig { returns(T.untyped) }
    def svg_available?
      AssetFinder.find_asset(svg_path(locale))
    end

    sig { params(locale: T.nilable(T.any(String, Symbol))).returns(String) }
    def svg_path(locale)
      "#{base_path(locale)}.svg"
    end

    sig { params(locale: T.nilable(T.any(String, Symbol))).returns(String) }
    def png_path(locale)
      "#{base_path(locale)}.png"
    end

    sig { params(locale: T.nilable(T.any(String, Symbol))).returns(String) }
    def base_path(locale)
      "sdg/#{locale}/goal_#{code}"
    end
end
