# typed: strict
class Admin::SiteCustomization::ContentBlocks::FormHeadingContentBlockComponent < ApplicationComponent
  sig { returns(Budget::ContentBlock) }
  attr_reader :content_block

  delegate :valid_blocks, to: :helpers

  sig { params(content_block: Budget::ContentBlock).void }
  def initialize(content_block)
    @content_block = content_block
  end

  private

    sig { returns(String) }
    def selected_content_block
      "hcb_#{content_block.heading_id}"
    end
end
