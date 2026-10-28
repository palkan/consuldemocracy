# typed: strict
module Taggable
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ApplicationRecord }

  included do
    acts_as_taggable_on :tags, :ml_tags
    validate :max_number_of_tags, on: :create
    before_validation :sanitize_tag_list
  end

  sig { returns(ActsAsTaggableOn::Tag::PrivateCollectionProxy) }
  def tags_list
    if Tag.machine_learning? && (is_a?(Proposal) || is_a?(Budget::Investment))
      ml_tags
    else
      tags
    end
  end

  sig do
    params(limit: T.nilable(Integer))
      .returns(T.any(ActsAsTaggableOn::Tag::PrivateCollectionProxy, T::Array[ActsAsTaggableOn::Tag]))
  end
  def tag_list_with_limit(limit = nil)
    return tags_list if limit.blank?

    T.must(tags_list.sort { |a, b| T.must(b.taggings_count <=> a.taggings_count) }[0, limit])
  end

  sig { void }
  def max_number_of_tags
    errors.add(:tag_list, :less_than_or_equal_to, count: 6) if tag_list.count > 6
  end

  protected

    sig { void }
    def sanitize_tag_list
      self.tag_list = TagSanitizer.new.sanitize_tag_list(tag_list)
    end
end
