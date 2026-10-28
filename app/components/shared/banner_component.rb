# typed: strict
class Shared::BannerComponent < ApplicationComponent
  sig { returns(T.nilable(T.any(Banner, String))) }
  attr_reader :banner_or_section

  sig { params(banner_or_section: T.nilable(T.any(Banner, String))).void }
  def initialize(banner_or_section)
    @banner_or_section = banner_or_section
    @banner = T.let(nil, T.nilable(Banner))
  end

  sig { returns(T.nilable(Banner)) }
  def banner
    @banner ||= if banner_or_section.respond_to?(:sections)
                  T.cast(banner_or_section, Banner)
                else
                  Banner.in_section(banner_or_section).with_active.sample
                end
  end

  sig { returns(T.nilable(T::Boolean)) }
  def render?
    banner = self.banner
    banner && (banner.title.present? || banner.description.present?)
  end

  private

    sig { returns(ActiveSupport::SafeBuffer) }
    def banner_content
      banner = T.must(self.banner)

      tag.h2(link_to(banner.title, banner.target_url), style: "color:#{banner.font_color}") +
        tag.h3(banner.description, style: "color:#{banner.font_color}")
    end
end
