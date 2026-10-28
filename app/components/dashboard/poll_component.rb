# typed: strict
class Dashboard::PollComponent < ApplicationComponent
  sig { returns(Poll) }
  attr_reader :poll

  sig { params(poll: Poll).void }
  def initialize(poll)
    @poll = poll
  end

  private

    sig { returns(Proposal) }
    def proposal
      poll.related
    end
end
