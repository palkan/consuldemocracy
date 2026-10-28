# typed: strict
class Polls::PollHeaderComponent < ApplicationComponent
  sig { returns(Poll) }
  attr_reader :poll

  delegate :auto_link_already_sanitized_html, to: :helpers

  sig { params(poll: Poll).void }
  def initialize(poll)
    @poll = poll
  end
end
