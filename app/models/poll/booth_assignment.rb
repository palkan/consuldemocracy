# typed: strict
class Poll
  class BoothAssignment < ApplicationRecord
    belongs_to :booth
    belongs_to :poll

    delegate :name, to: :booth

    before_destroy :destroy_poll_shifts

    has_many :officer_assignments, dependent: :destroy
    has_many :officers, through: :officer_assignments
    has_many :voters
    has_many :partial_results
    has_many :recounts

    sig { returns(T::Boolean) }
    def shifts?
      !shifts.empty?
    end

    sig { returns(T::Boolean) }
    def unable_to_destroy?
      (partial_results.count + recounts.count).positive?
    end

    private

      sig { returns(Poll::Shift::PrivateRelation) }
      def shifts
        Poll::Shift.where(booth_id: booth_id,
                          officer_id: officer_assignments.pluck(:officer_id),
                          date: officer_assignments.pluck(:date))
      end

      sig { void }
      def destroy_poll_shifts
        shifts.destroy_all
      end
  end
end
