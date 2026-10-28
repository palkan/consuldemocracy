# typed: strict
class Budgets::Investments::ContentBlocksComponent < ApplicationComponent
  sig { returns(T.nilable(Budget::Heading)) }
  attr_reader :heading

  sig { params(heading: T.nilable(Budget::Heading)).void }
  def initialize(heading)
    @heading = heading
  end

  sig { returns(T.nilable(T::Boolean)) }
  def render?
    heading&.allow_custom_content && content_blocks.any?
  end

  private

    sig { returns(Budget::ContentBlock::PrivateAssociationRelation) }
    def content_blocks
      T.must(heading).content_blocks.where(locale: I18n.locale)
    end
end
