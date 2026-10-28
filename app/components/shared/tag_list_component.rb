# typed: strict
class Shared::TagListComponent < ApplicationComponent
  sig { returns(T.untyped) }
  attr_reader :taggable

  sig { returns(T.nilable(Integer)) }
  attr_reader :limit

  delegate :link_list, to: :helpers

  sig { params(taggable: T.untyped, limit: T.nilable(Integer)).void }
  def initialize(taggable, limit:)
    @taggable = taggable
    @limit = limit
  end

  sig { returns(T::Boolean) }
  def render?
    taggable.tags_list.any?
  end

  private

    sig { returns(T::Array[T.untyped]) }
    def links
      [*tag_links, see_more_link]
    end

    sig { returns(T::Array[T::Array[T.untyped]]) }
    def tag_links
      taggable.tag_list_with_limit(limit).map do |tag|
        [
          sanitize(tag.name),
          taggables_path(taggable, tag.name)
        ]
      end
    end

    sig { returns(String) }
    def see_more_link
      render Shared::SeeMoreLinkComponent.new(taggable, :tags_list, limit: limit)
    end

    sig { params(taggable: T.untyped, tag_name: String).returns(String) }
    def taggables_path(taggable, tag_name)
      case taggable.class.name
      when "Legislation::Proposal"
        legislation_process_proposals_path(taggable.process, search: tag_name)
      else
        polymorphic_path(taggable.class, search: tag_name)
      end
    end

    sig { returns(T::Boolean) }
    def machine_learning?
      Tag.machine_learning?
    end
end
