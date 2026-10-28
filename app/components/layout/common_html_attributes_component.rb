# typed: strict
class Layout::CommonHtmlAttributesComponent < ApplicationComponent
  delegate :rtl?, to: :helpers

  private

    sig { returns(ActiveSupport::SafeBuffer) }
    def attributes
      tag.attributes(dir: dir, lang: lang, class: html_class, data: data)
    end

    sig { returns(T.nilable(String)) }
    def dir
      "rtl" if rtl?
    end

    sig { returns(T.any(Symbol, FalseClass)) }
    def lang
      I18n.locale
    end

    sig { returns(T.nilable(String)) }
    def html_class
      "tenant-#{Tenant.current_schema}" if Rails.application.config.multitenancy
    end

    sig { returns(T::Hash[Symbol, T.nilable(String)]) }
    def data
      { warning_for_external_links: warning_for_external_links_text }
    end

    sig { returns(T.nilable(String)) }
    def warning_for_external_links_text
      t("shared.warning_for_external_links") if feature?("gdpr.warning_for_external_links")
    end
end
