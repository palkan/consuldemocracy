# typed: strict
class Shared::LinkListComponent < ApplicationComponent
  sig { returns(T::Array[T.untyped]) }
  attr_reader :links

  sig { returns(T::Hash[Symbol, T.untyped]) }
  attr_reader :options

  sig { params(links: T.untyped, options: T.untyped).void }
  def initialize(*links, **options)
    @links = links
    @options = options
  end

  sig { returns(T::Boolean) }
  def render?
    present_links.any?
  end

  private

    sig { returns(T::Array[T.untyped]) }
    def present_links
      links.compact_blank
    end

    sig { returns(T::Array[ActiveSupport::SafeBuffer]) }
    def list_items
      present_links.map do |text, url, current_or_options = false, options = {}|
        if current_or_options.is_a?(Hash)
          current = false
          link_options = current_or_options
        else
          current = current_or_options
          link_options = options
        end

        tag.li("aria-current": (true if current)) do
          if url
            link_to text, url, link_options
          else
            text
          end
        end
      end
    end
end
