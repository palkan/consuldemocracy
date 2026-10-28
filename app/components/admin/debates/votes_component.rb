# typed: strict
class Admin::Debates::VotesComponent < ApplicationComponent
  sig { returns(Debate) }
  attr_reader :debate

  delegate :votes_percentage, to: :helpers

  sig { params(debate: Debate).void }
  def initialize(debate)
    @debate = debate
  end
end
