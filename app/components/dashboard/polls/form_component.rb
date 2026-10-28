# typed: strict
class Dashboard::Polls::FormComponent < ApplicationComponent
  sig { returns(Poll) }
  attr_reader :poll

  delegate :admin_submit_action, to: :helpers

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
