# typed: strict
module CommunitiesHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params(community: Community).returns(T.nilable(String)) }
  def community_title(community)
    community.from_proposal? ? T.must(community.proposal).title : T.must(community.investment).title
  end

  sig { params(community: Community).returns(String) }
  def community_text(community)
    community.from_proposal? ? t("community.show.title.proposal") : t("community.show.title.investment")
  end

  sig { params(community: Community).returns(String) }
  def community_description(community)
    if community.from_proposal?
      t("community.show.description.proposal")
    else
      t("community.show.description.investment")
    end
  end

  sig { params(community: Community, participant: User).returns(T::Boolean) }
  def author?(community, participant)
    if community.from_proposal?
      T.must(community.proposal).author_id == participant.id
    else
      T.must(community.investment).author_id == participant.id
    end
  end

  sig { params(community: Community).returns(String) }
  def community_back_link_path(community)
    if community.from_proposal?
      proposal_path(community.proposal)
    else
      budget_investment_path(T.must(community.investment).budget_id, community.investment)
    end
  end

  sig { params(community: Community).returns(String) }
  def community_access_text(community)
    if community.from_proposal?
      t("community.sidebar.description.proposal")
    else
      t("community.sidebar.description.investment")
    end
  end

  sig { params(community: Community).returns(String) }
  def create_topic_link(community)
    current_user.present? ? new_community_topic_path(community.id) : new_user_session_path
  end
end
