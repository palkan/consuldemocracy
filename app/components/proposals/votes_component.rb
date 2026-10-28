# typed: strict
class Proposals::VotesComponent < ApplicationComponent
  sig { returns(Proposal) }
  attr_reader :proposal

  delegate :link_to_verify_account, to: :helpers

  sig { params(proposal: Proposal, vote_url: T.nilable(String)).void }
  def initialize(proposal, vote_url: nil)
    @proposal = proposal
    @vote_url = vote_url
  end

  sig { returns(String) }
  def vote_url
    @vote_url || vote_proposal_path(proposal, value: "yes")
  end

  private

    sig { returns(T.nilable(T::Boolean)) }
    def voted?
      current_user&.voted_for?(proposal)
    end

    sig { returns(T.nilable(T::Boolean)) }
    def can_vote?
      proposal.votable_by?(current_user)
    end

    sig { returns(String) }
    def support_aria_label
      t("proposals.proposal.support_label", proposal: proposal.title)
    end

    sig { returns(T.nilable(String)) }
    def cannot_vote_text
      t("votes.verified_only", verify_account: link_to_verify_account) unless can_vote?
    end
end
