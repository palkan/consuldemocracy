# typed: strict
module Sluggable
  extend ActiveSupport::Concern
  extend T::Sig

  included do
    before_validation :generate_slug, if: :generate_slug?
  end

  module ClassMethods
    extend T::Generic
    extend T::Helpers
    extend T::Sig

    has_attached_class!(:out)
    requires_ancestor { T.class_of(ApplicationRecord) }

    sig { params(slug_or_id: T.untyped).returns(T.nilable(T.attached_class)) }
    def find_by_slug_or_id(slug_or_id)
      find_by(slug: slug_or_id) || find_by(id: slug_or_id)
    end

    sig { params(slug_or_id: T.untyped).returns(T.attached_class) }
    def find_by_slug_or_id!(slug_or_id)
      find_by(slug: slug_or_id) || find(slug_or_id)
    end
  end

  sig { void }
  def generate_slug
    self.slug = name.to_s.parameterize
  end
end
