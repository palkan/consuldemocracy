# typed: true
class Admin::ProposalProgressBarsController < Admin::ProgressBarsController
  private

    sig { returns(Proposal) }

    def progressable
      Proposal.find(params[:proposal_id])
    end
end
