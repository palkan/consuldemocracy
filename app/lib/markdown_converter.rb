# typed: strict
class MarkdownConverter
  extend T::Sig

  sig { returns(T.nilable(String)) }
  attr_reader :text

  sig { returns(T::Hash[Symbol, T.untyped]) }
  attr_reader :render_options

  sig { params(text: T.nilable(String), render_options: T.untyped).void }
  def initialize(text, **render_options)
    @text = text
    @render_options = render_options
  end

  sig { returns(T.nilable(String)) }
  def render
    return text if text.blank?

    AdminLegislationSanitizer.new.sanitize(Redcarpet::Markdown.new(renderer, extensions).render(text))
  end

  sig { returns(String) }
  def render_toc
    Redcarpet::Markdown.new(toc_renderer).render(text)
  end

  private

    sig { returns(Redcarpet::Render::HTML) }
    def renderer
      Redcarpet::Render::HTML.new(default_render_options.merge(render_options))
    end

    sig { returns(Redcarpet::Render::HTML_TOC) }
    def toc_renderer
      Redcarpet::Render::HTML_TOC.new(with_toc_data: true)
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def default_render_options
      {
        filter_html: false,
        hard_wrap: true,
        link_attributes: {}
      }
    end

    sig { returns(T::Hash[Symbol, T::Boolean]) }
    def extensions
      {
        autolink: true,
        fenced_code_blocks: true,
        lax_spacing: true,
        no_intra_emphasis: true,
        strikethrough: true,
        superscript: true,
        tables: true
      }
    end
end
