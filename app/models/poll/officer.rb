# typed: strict
class Poll
  class Officer < ApplicationRecord
    belongs_to :user
    has_many :officer_assignments
    has_many :shifts
    has_many :failed_census_calls, foreign_key: :poll_officer_id, inverse_of: :poll_officer

    validates :user_id, presence: true, uniqueness: true

    sig { returns(String) }
    def name
      user&.name || I18n.t("shared.author_info.author_deleted")
    end

    sig { returns(String) }
    def email
      user&.email || I18n.t("shared.author_info.email_deleted")
    end

    sig { returns(T::Array[Poll]) }
    def voting_days_assigned_polls
      officer_assignments.voting_days
                         .includes(booth_assignment: :poll)
                         .map(&:booth_assignment)
                         .map { |booth_assignment| T.must(booth_assignment).poll }.uniq.compact
                         .sort { |x, y| y.ends_at <=> x.ends_at }
    end

    sig { returns(T::Array[Poll]) }
    def final_days_assigned_polls
      officer_assignments.final
                         .includes(booth_assignment: :poll)
                         .map(&:booth_assignment)
                         .map { |booth_assignment| T.must(booth_assignment).poll }.uniq.compact
                         .sort { |x, y| y.ends_at <=> x.ends_at }
    end

    sig { returns(T::Array[T.nilable(Poll::Booth)]) }
    def todays_booths
      officer_assignments.by_date(Date.current).map(&:booth).uniq
    end
  end
end
