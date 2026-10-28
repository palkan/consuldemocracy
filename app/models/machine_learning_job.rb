# typed: strict
class MachineLearningJob < ApplicationRecord
  belongs_to :user, optional: false

  sig { returns(T::Boolean) }
  def started?
    started_at.present?
  end

  sig { returns(T::Boolean) }
  def finished?
    finished_at.present?
  end

  sig { returns(T::Boolean) }
  def errored?
    error.present?
  end

  sig { returns(T::Boolean) }
  def running_for_too_long?
    started? && !finished? && T.must(started_at) < 1.day.ago
  end
end
