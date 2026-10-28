# typed: strict
class Dashboard::DefaultResourceComponent < ApplicationComponent
  sig { returns(String) }
  attr_reader :resource

  sig { returns(Proposal) }
  attr_reader :proposal

  sig { params(resource: String, proposal: Proposal).void }
  def initialize(resource, proposal)
    @resource = resource
    @proposal = proposal
  end

  sig { returns(T::Boolean) }
  def render?
    can?(:"manage_#{resource}", proposal)
  end

  sig { returns(T.nilable(String)) }
  def resource_description
    if resource == "mailing"
      Setting["proposals.email_short_title"]
    else
      Setting["proposals.#{resource}_short_title"]
    end
  end

  sig { returns(String) }
  def resource_path
    if resource == "polls"
      proposal_dashboard_polls_path(proposal)
    else
      send("new_proposal_dashboard_#{resource}_path", proposal)
    end
  end
end
