# typed: strict
module ContentBlocksHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { returns(T::Array[[String, String]]) }
  def valid_blocks
    options = SiteCustomization::ContentBlock::VALID_BLOCKS.map do |key|
      [t("admin.site_customization.content_blocks.content_block.names.#{key}"), key]
    end
    Budget::Heading.allow_custom_content.each do |heading|
      options.push([heading.name, "hcb_#{heading.id}"])
    end
    options
  end
end
