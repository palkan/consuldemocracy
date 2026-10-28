# typed: strict
class Polls::FormComponent < ApplicationComponent
  sig { returns(Poll::WebVote) }
  attr_reader :web_vote

  delegate :poll, :questions, to: :web_vote

  sig { params(web_vote: Poll::WebVote).void }
  def initialize(web_vote)
    @web_vote = web_vote
  end

  private

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def form_attributes
      { url: answer_poll_path(poll), method: :post, html: { class: "poll-form" }}
    end

    sig { returns(T::Boolean) }
    def disabled?
      cannot?(:answer, poll) || poll.voted_in_booth?(current_user)
    end
end
