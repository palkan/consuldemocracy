# typed: strict
class Admin::SiteCustomization::ContentBlocks::FormContentBlockComponent < ApplicationComponent
  sig { returns(SiteCustomization::ContentBlock) }
  attr_reader :content_block

  delegate :valid_blocks, to: :helpers

  sig { params(content_block: SiteCustomization::ContentBlock).void }
  def initialize(content_block)
    @content_block = content_block
  end

  private

    sig { returns(T.nilable(String)) }
    def selected_content_block
      content_block.name
    end
end
