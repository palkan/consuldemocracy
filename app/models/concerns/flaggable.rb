# typed: strict
module Flaggable
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ApplicationRecord }

  included do
    has_many :flags, as: :flaggable, inverse_of: :flaggable
    scope :flagged, -> { where(flags_count: 1..) }
    scope :pending_flag_review, -> { flagged.where(ignored_flag_at: nil, hidden_at: nil) }
    scope :with_ignored_flag, -> { flagged.where.not(ignored_flag_at: nil).where(hidden_at: nil) }
  end

  sig { returns(T::Boolean) }
  def ignored_flag?
    ignored_flag_at.present?
  end

  sig { returns(T::Boolean) }
  def ignore_flag
    update(ignored_flag_at: Time.current)
  end
end
