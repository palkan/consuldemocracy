# typed: strict
class Admin::Proposals::IndexComponent < ApplicationComponent
  include Header

  sig { returns(Proposal::PrivateRelation) }
  attr_reader :proposals

  sig { params(proposals: Proposal::PrivateRelation).void }
  def initialize(proposals)
    @proposals = proposals
  end

  sig { override.returns(String) }
  def title
    t("admin.proposals.index.title")
  end

  private

    sig { returns(T.nilable(ActiveSupport::SafeBuffer)) }
    def successful_proposals_link
      if Proposal.successful.any?
        link_to t("admin.questions.index.successful_proposals_tab"), successful_admin_proposals_path
      end
    end
end
