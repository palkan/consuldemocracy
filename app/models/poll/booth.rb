# typed: strict
class Poll
  class Booth < ApplicationRecord
    has_many :booth_assignments
    has_many :polls, through: :booth_assignments
    has_many :shifts

    validates :name, presence: true, uniqueness: true

    sig { params(terms: T.nilable(String)).returns(Poll::Booth::PrivateRelation) }
    def self.search(terms)
      Booth.where("name ILIKE ? OR location ILIKE ?", "%#{terms}%", "%#{terms}%")
    end

    sig { params(terms: T.nilable(String)).returns(Poll::Booth::PrivateRelation) }
    def self.quick_search(terms)
      if terms.blank?
        Booth.none
      else
        search(terms)
      end
    end

    sig { returns(T.any(Poll::Booth::PrivateRelation, Poll::Booth::PrivateAssociationRelation)) }
    def self.available
      where(polls: { id: Poll.current_or_recounting }).joins(:polls)
    end

    sig { params(poll: Poll).returns(T.nilable(Poll::BoothAssignment)) }
    def assignment_on_poll(poll)
      booth_assignments.find_by(poll: poll)
    end
  end
end
