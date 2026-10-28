# typed: strict
class Officing::BallotSheets::ShowComponent < ApplicationComponent
  sig { returns(Poll::BallotSheet) }
  attr_reader :ballot_sheet

  sig { params(ballot_sheet: Poll::BallotSheet).void }
  def initialize(ballot_sheet)
    @ballot_sheet = ballot_sheet
  end
end
