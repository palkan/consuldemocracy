# typed: strict
class Shared::ParticipationNotAllowedComponent < ApplicationComponent
  sig { returns(T.any(Budget::Investment, Debate, Legislation::Proposal, Proposal)) }
  attr_reader :votable

  sig { returns(T.nilable(String)) }
  attr_reader :cannot_vote_text

  delegate :link_to_signin, :link_to_signup, to: :helpers

  sig do
    params(
      votable: T.any(Budget::Investment, Debate, Legislation::Proposal, Proposal),
      cannot_vote_text: T.nilable(String)
    ).void
  end
  def initialize(votable, cannot_vote_text:)
    @votable = votable
    @cannot_vote_text = cannot_vote_text
    @body = T.let(nil, T.nilable(ActiveSupport::SafeBuffer))
  end

  sig { returns(T::Boolean) }
  def render?
    body.present?
  end

  private

    sig { returns(T.nilable(ActiveSupport::SafeBuffer)) }
    def body
      @body ||=
        if !current_user
          sanitize(t("users.login_to_continue", signin: link_to_signin, signup: link_to_signup))
        elsif organization?
          tag.p t("votes.organizations")
        elsif cannot_vote_text.present?
          tag.p sanitize(cannot_vote_text)
        end
    end

    sig { returns(T.nilable(T::Boolean)) }
    def organization?
      current_user&.organization?
    end
end
