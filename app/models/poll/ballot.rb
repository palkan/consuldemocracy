# typed: strict
class Poll::Ballot < ApplicationRecord
  belongs_to :ballot_sheet

  validates :ballot_sheet_id, presence: true

  sig { void }
  def verify
    investments.each do |investment_id|
      add_investment(investment_id)
    end
  end

  sig { params(investment_id: T.any(Integer, String)).returns(T.nilable(Budget::Ballot::Line)) }
  def add_investment(investment_id)
    investment = find_investment(investment_id)

    if investment.present? && not_already_added?(investment)
      T.must(ballot).add_investment(investment)
    end
  end

  sig { returns(T::Array[String]) }
  def investments
    T.must(data).split(",")
  end

  sig { returns(T.nilable(Budget::Ballot)) }
  def ballot
    Budget::Ballot.find_by(poll_ballot: self)
  end

  sig { params(investment_id: T.any(Integer, String)).returns(T.nilable(Budget::Investment)) }
  def find_investment(investment_id)
    T.must(T.must(ballot).budget).investments.find_by(id: investment_id)
  end

  sig { params(investment: Budget::Investment).returns(T::Boolean) }
  def not_already_added?(investment)
    T.must(ballot).lines.where(investment: investment).blank?
  end
end
