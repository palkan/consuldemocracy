# typed: strict
class Admin::Proposals::SuccessfulComponent < ApplicationComponent
  include Header

  sig { returns(Proposal::PrivateRelation) }
  attr_reader :proposals

  sig { params(proposals: Proposal::PrivateRelation).void }
  def initialize(proposals)
    @proposals = proposals
  end

  sig { override.returns(String) }
  def title
    t("admin.questions.index.successful_proposals_tab")
  end
end
