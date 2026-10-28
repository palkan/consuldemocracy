# typed: strict
class Dashboard::PollsComponent < ApplicationComponent
  sig { returns(Poll::PrivateRelation) }
  attr_reader :polls

  sig { params(polls: Poll::PrivateRelation).void }
  def initialize(polls)
    @polls = polls
  end

  sig { returns(T::Boolean) }
  def render?
    polls.any?
  end
end
