# typed: strict
class Proposals::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  sig { returns(Proposal) }
  attr_reader :proposal

  sig { returns(String) }
  attr_reader :url

  delegate :suggest_data, :geozone_select_options, to: :helpers

  sig { params(proposal: Proposal, url: String).void }
  def initialize(proposal, url:)
    @proposal = proposal
    @url = url
  end

  private

    sig { returns(MapLocation) }
    def map_location
      proposal.map_location || MapLocation.new(proposal: Proposal.new)
    end
end
