# typed: strict
class Proposals::SummaryComponent < ApplicationComponent
  ProposalsByCategory = T.type_alias do
    T::Hash[String, T.any(Proposal::PrivateRelation, Proposal::PrivateAssociationRelation)]
  end

  sig { returns(ProposalsByCategory) }
  attr_reader :proposals

  sig { params(proposals: ProposalsByCategory).void }
  def initialize(proposals)
    @proposals = proposals
  end
end
