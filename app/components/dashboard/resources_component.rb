# typed: strict
class Dashboard::ResourcesComponent < ApplicationComponent
  sig { returns(Proposal) }
  attr_reader :proposal

  sig { returns(T.nilable(T::Array[Integer])) }
  attr_reader :new_actions_since_last_login

  sig { params(proposal: Proposal, new_actions_since_last_login: T.nilable(T::Array[Integer])).void }
  def initialize(proposal, new_actions_since_last_login = [])
    @proposal = proposal
    @new_actions_since_last_login = new_actions_since_last_login
    @active_resources = T.let(nil, T.nilable(Dashboard::Action::PrivateRelation))
  end

  private

    sig { returns(T::Array[String]) }
    def default_resources
      %w[polls mailing poster]
    end

    sig { returns(Dashboard::Action::PrivateRelation) }
    def active_resources
      @active_resources ||= Dashboard::Action.active
                                             .resources
                                             .by_proposal(proposal)
                                             .order(required_supports: :asc, day_offset: :asc)
    end
end
