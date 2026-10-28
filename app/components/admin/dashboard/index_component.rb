# typed: strict
class Admin::Dashboard::IndexComponent < ApplicationComponent
  include Header

  sig { override.returns(String) }
  def title
    t("admin.dashboard.index.title")
  end

  private

    sig { returns(ActiveSupport::SafeBuffer) }
    def info
      sanitize t("admin.dashboard.index.info")
    end

    sig { returns(ActiveSupport::SafeBuffer) }
    def email_link
      mail_to "info@consulfoundation.org"
    end

    sig { returns(ActiveSupport::SafeBuffer) }
    def website_link
      link_to "https://consuldemocracy.org", "https://consuldemocracy.org"
    end
end
