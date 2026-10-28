# typed: true
class Admin::ProposalMilestonesController < Admin::MilestonesController
  private

    sig { returns(Proposal) }

    def milestoneable
      Proposal.find(params[:proposal_id])
    end
end
