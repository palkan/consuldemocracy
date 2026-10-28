# typed: strict
class Shared::GeozoneLinkComponent < ApplicationComponent
  sig { returns(T.any(Proposal, Legislation::Proposal)) }
  attr_reader :geozonable

  sig { returns(String) }
  attr_reader :link

  delegate :geozone_name, to: :helpers

  sig { params(geozonable: T.any(Proposal, Legislation::Proposal), link: String).void }
  def initialize(geozonable, link)
    @geozonable = geozonable
    @link = link
  end

  sig { returns(T::Boolean) }
  def render?
    Geozone.any?
  end
end
