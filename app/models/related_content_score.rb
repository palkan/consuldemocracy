# typed: strict
class RelatedContentScore < ApplicationRecord
  SCORES = T.let({ POSITIVE: 1, NEGATIVE: -1 }.freeze, { POSITIVE: Integer, NEGATIVE: Integer })

  belongs_to :related_content, touch: true, counter_cache: :related_content_scores_count
  belongs_to :user

  validates :user, presence: true
  validates :related_content, presence: true
  validates :related_content_id, uniqueness: { scope: [:user_id] }
end
