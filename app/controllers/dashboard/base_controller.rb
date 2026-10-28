# typed: true
class Dashboard::BaseController < ApplicationController
  before_action :authenticate_user!, :detect_new_actions_after_last_login

  include Dashboard::HasProposal

  helper_method :proposal, :proposed_actions, :resource, :resources, :next_goal,
                :next_goal_supports, :next_goal_progress, :community_members_count

  respond_to :html
  layout "dashboard"

  private

    sig { returns(Dashboard::Action::PrivateRelation) }
    def proposed_actions
      @proposed_actions ||= Dashboard::Action.proposed_actions.active_for(proposal)
                                             .order(order: :asc)
    end

    sig { returns(Dashboard::Action::PrivateRelation) }
    def resources
      @resources ||= Dashboard::Action.resources.active_for(proposal).order(order: :asc)
    end

    sig { returns(T.nilable(T.any(Integer, String))) }
    def next_goal_supports
      @next_goal_supports ||= next_goal&.required_supports || Setting["votes_for_proposal_success"]
    end

    sig { returns(Integer) }
    def next_goal_progress
      @next_goal_progress ||= (proposal.votes_for.size * 100) / next_goal_supports.to_i
    end

    sig { returns(Integer) }
    def community_members_count
      community = T.must(proposal.community)

      Rails.cache.fetch("community/#{community.id}/participants_count",
                        expires_in: 1.hour) do
        community.participants.count
      end
    end

    sig { returns(T.nilable(Dashboard::Action)) }
    def next_goal
      @next_goal ||= Dashboard::Action.next_goal_for(proposal)
    end

    sig { void }
    def detect_new_actions_after_last_login
      author_last_login = T.must(T.must(proposal.author).last_sign_in_at).to_date
      @new_actions_since_last_login = Dashboard::Action.detect_new_actions_since(author_last_login,
                                                                                 proposal)
    end
end
