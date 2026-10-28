# typed: strict
class Legislation::Proposals::VotesComponent < ApplicationComponent
  sig { returns(Legislation::Proposal) }
  attr_reader :proposal

  delegate :link_to_verify_account, to: :helpers

  sig { params(proposal: Legislation::Proposal).void }
  def initialize(proposal)
    @proposal = proposal
  end

  private

    sig { returns(T::Boolean) }
    def can_vote?
      can?(:create, proposal.votes_for.new(voter: current_user))
    end

    sig { returns(T.nilable(String)) }
    def cannot_vote_text
      t("legislation.proposals.not_verified", verify_account: link_to_verify_account) unless can_vote?
    end
end
