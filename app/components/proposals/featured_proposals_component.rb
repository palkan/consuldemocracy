# typed: strict
class Proposals::FeaturedProposalsComponent < ApplicationComponent
  sig { returns(T.nilable(Proposal::PrivateRelation)) }
  attr_reader :proposals

  sig { params(proposals: T.nilable(Proposal::PrivateRelation)).void }
  def initialize(proposals)
    @proposals = proposals
  end

  sig { returns(T.nilable(T::Boolean)) }
  def render?
    params[:selected].blank? && proposals.present?
  end
end
