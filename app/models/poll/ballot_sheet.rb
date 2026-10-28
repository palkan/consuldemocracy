# typed: strict
class Poll::BallotSheet < ApplicationRecord
  belongs_to :poll
  belongs_to :officer_assignment
  has_many :ballots

  validates :data, presence: true
  validates :poll_id, presence: true
  validates :officer_assignment_id, presence: true

  after_create :verify_ballots

  sig { returns(String) }
  def author
    T.must(T.must(officer_assignment).officer).name
  end

  sig { void }
  def verify_ballots
    parsed_ballots.each_with_index do |investment_ids, index|
      ballot = create_ballots(investment_ids, index)
      ballot.verify
    end
  end

  sig { returns(T::Array[String]) }
  def parsed_ballots
    T.must(data).split(/[;\n]/)
  end

  private

    sig { params(investment_ids: String, index: Integer).returns(Poll::Ballot) }
    def create_ballots(investment_ids, index)
      poll_ballot = Poll::Ballot.where(ballot_sheet: self,
                                       data: investment_ids,
                                       external_id: index).first_or_create!
      create_ballot(poll_ballot)
      poll_ballot
    end

    sig { params(poll_ballot: Poll::Ballot).returns(Budget::Ballot) }
    def create_ballot(poll_ballot)
      Budget::Ballot.where(physical: true,
                           user: nil,
                           poll_ballot: poll_ballot,
                           budget: T.must(poll).budget).first_or_create!
    end
end
