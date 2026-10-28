# typed: strict
class Polls::ResultsComponent < ApplicationComponent
  sig { returns(Poll) }
  attr_reader :poll

  sig { params(poll: Poll).void }
  def initialize(poll)
    @poll = poll
  end
end
