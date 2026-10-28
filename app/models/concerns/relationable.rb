# typed: strict
module Relationable
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ApplicationRecord }

  included do
    has_many :related_contents,
             as: :parent_relationable,
             inverse_of: :parent_relationable,
             dependent: :destroy
  end

  sig { params(relationable: T.nilable(ApplicationRecord)).returns(T.nilable(RelatedContent)) }
  def find_related_content(relationable)
    RelatedContent.find_by(parent_relationable: self, child_relationable: relationable)
  end

  sig { returns(T::Array[T.untyped]) }
  def relationed_contents
    if MachineLearning.enabled? && Setting["machine_learning.related_content"].present?
      related_content = related_contents.not_hidden.order(machine_learning_score: :desc)
    else
      related_content = related_contents.not_hidden.from_users
    end

    related_content.map(&:child_relationable).reject do |related|
      related.respond_to?(:retired?) && related.retired?
    end
  end
end
