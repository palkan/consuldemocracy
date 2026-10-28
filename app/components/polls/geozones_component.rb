# typed: strict
class Polls::GeozonesComponent < ApplicationComponent
  sig { returns(Poll) }
  attr_reader :poll

  sig { params(poll: Poll).void }
  def initialize(poll)
    @poll = poll
  end

  sig { returns(T::Boolean) }
  def render?
    poll.geozones.any?
  end
end
