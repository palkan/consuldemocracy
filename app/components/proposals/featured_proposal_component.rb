# typed: strict
class Proposals::FeaturedProposalComponent < ApplicationComponent
  sig { returns(Proposal) }
  attr_reader :proposal

  sig { params(proposal: Proposal).void }
  def initialize(proposal)
    @proposal = proposal
  end
end
