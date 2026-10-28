# typed: strict
module Dashboard::HasProposal
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ActionController::Base }

  sig { returns(Proposal) }
  def proposal
    @proposal ||= T.let(Proposal.includes(:community).find(params[:proposal_id]), T.nilable(Proposal))
  end
end
