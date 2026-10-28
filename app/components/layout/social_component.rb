# typed: strict
class Layout::SocialComponent < ApplicationComponent
  delegate :content_block, to: :helpers

  sig { returns(T::Boolean) }
  def render?
    sites.any? || footer_content_block.present?
  end

  private

    sig { returns(T::Hash[Symbol, String]) }
    def sites
      {
        twitter: "https://twitter.com",
        facebook: "https://www.facebook.com",
        youtube: "https://www.youtube.com",
        telegram: "https://www.telegram.me",
        instagram: "https://www.instagram.com"
      }.select { |name, _| setting["#{name}_handle"].present? }
    end

    sig { params(site_name: Symbol).returns(String) }
    def link_title(site_name)
      t("shared.go_to_page") + link_text(site_name)
    end

    sig { params(site_name: Symbol).returns(String) }
    def link_text(site_name)
      t("social.#{site_name}", org: setting["org_name"])
    end

    sig { returns(T.nilable(String)) }
    def footer_content_block
      content_block("footer")
    end
end
