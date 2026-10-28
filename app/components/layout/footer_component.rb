# typed: strict
class Layout::FooterComponent < ApplicationComponent
  sig { returns(T::Boolean) }
  def render?
    !Rails.application.multitenancy_management_mode?
  end

  private

    sig { returns(ActiveSupport::SafeBuffer) }
    def open_source_link
      external_link_to(t("layouts.footer.open_source"), t("layouts.footer.open_source_url"))
    end

    sig { returns(ActiveSupport::SafeBuffer) }
    def repository_link
      external_link_to(t("layouts.footer.consul"), t("layouts.footer.consul_url"))
    end

    sig { params(text: String, url: String).returns(ActiveSupport::SafeBuffer) }
    def external_link_to(text, url)
      link_to(text, url, rel: "nofollow external")
    end

    sig { returns(T::Set[String]) }
    def allowed_link_attributes
      self.class.sanitized_allowed_attributes + ["rel"]
    end
end
