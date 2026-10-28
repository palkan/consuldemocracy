# typed: strict
module Milestoneable
  extend ActiveSupport::Concern
  extend T::Sig

  included do
    has_many :milestones, as: :milestoneable, inverse_of: :milestoneable, dependent: :destroy

    scope :with_milestones, -> { joins(:milestones).distinct }

    has_many :progress_bars, as: :progressable, inverse_of: :progressable

    acts_as_taggable_on :milestone_tags
  end

  sig { returns(T.nilable(ProgressBar)) }
  def primary_progress_bar
    progress_bars.primary.first
  end

  sig { returns(ProgressBar::PrivateAssociationRelation) }
  def secondary_progress_bars
    progress_bars.secondary
  end
end
