# typed: strict
class Proposals::NewComponent < ApplicationComponent
  include Header

  sig { returns(Proposal) }
  attr_reader :proposal

  delegate :new_window_link_to, to: :helpers

  sig { params(proposal: Proposal).void }
  def initialize(proposal)
    @proposal = proposal
  end

  sig { override.returns(String) }
  def title
    t("proposals.new.start_new")
  end
end
