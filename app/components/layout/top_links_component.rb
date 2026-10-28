# typed: strict
class Layout::TopLinksComponent < ApplicationComponent
  delegate :content_block, to: :helpers

  sig { returns(T::Boolean) }
  def render?
    top_links_content_block.present?
  end

  private

    sig { returns(T.nilable(String)) }
    def top_links_content_block
      content_block("top_links")
    end
end
