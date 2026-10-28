# typed: strict
require "consul/repository"

class Layout::LegalLinksComponent < ApplicationComponent
  delegate :content_block, to: :helpers

  sig { returns(T.nilable(String)) }
  def footer_legal_content_block
    content_block("footer_legal")
  end

  private

    sig { returns(ActiveSupport::SafeBuffer) }
    def privacy_link
      link_to t("layouts.footer.privacy"), page_path("privacy")
    end

    sig { returns(ActiveSupport::SafeBuffer) }
    def conditions_link
      link_to t("layouts.footer.conditions"), page_path("conditions")
    end

    sig { returns(ActiveSupport::SafeBuffer) }
    def accessibility_link
      link_to t("layouts.footer.accessibility"), page_path("accessibility")
    end

    # This link makes it easy to comply with the AGPL. Remember that,
    # to comply with the AGPL, any person visiting your website must
    # also have (read) access to your source code.
    sig { returns(ActiveSupport::SafeBuffer) }
    def repo_link
      link_to t("layouts.footer.source_code"), repo_url, rel: "nofollow external"
    end

    sig { returns(String) }
    def repo_url
      Consul::Repository.url.delete_suffix(".git")
    end
end
