# typed: strict
module Header
  extend ActiveSupport::Concern
  extend T::Sig
  extend T::Helpers

  abstract!
  requires_ancestor { ApplicationComponent }

  sig do
    params(
      before: T.nilable(String),
      skip_section_title: T::Boolean,
      block: T.nilable(T.proc.void)
    ).returns(ActiveSupport::SafeBuffer)
  end
  def header(before: nil, skip_section_title: false, &block)
    provide(:title) do
      [
        (t("#{namespace}.header.title", default: "") unless skip_section_title),
        strip_tags(title),
        setting["org_name"]
      ].compact_blank.join(" - ")
    end

    heading_tag = if %w[admin management moderation sdg_management valuation].include?(namespace)
                    "h2"
                  else
                    "h1"
                  end

    tag.header do
      safe_join([before, content_tag(heading_tag, title), (capture(&block) if block)].compact)
    end
  end

  private

    sig { abstract.returns(T.nilable(String)) }
    def title; end

    sig { returns(String) }
    def namespace
      controller_path.split("/").first
    end
end
