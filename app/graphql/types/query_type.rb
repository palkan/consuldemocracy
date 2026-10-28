# typed: strict
module Types
  class QueryType < Types::BaseObject
    sig { params(name: Symbol, type: T.untyped).returns(T.nilable(Symbol)) }
    def self.collection_and_object_by_id_fields(name, type)
      collection_field name.to_s.pluralize.to_sym, type, "Returns all #{name.to_s.pluralize}", null: false
      object_by_id_field name, type, "Returns #{name} for ID", null: false
    end

    collection_and_object_by_id_fields :budget, Types::BudgetType
    collection_and_object_by_id_fields :comment, Types::CommentType
    collection_and_object_by_id_fields :debate, Types::DebateType
    collection_and_object_by_id_fields :geozone, Types::GeozoneType
    collection_and_object_by_id_fields :milestone, Types::MilestoneType
    collection_and_object_by_id_fields :proposal, Types::ProposalType
    collection_and_object_by_id_fields :proposal_notification, Types::ProposalNotificationType
    collection_and_object_by_id_fields :tag, Types::TagType
    collection_and_object_by_id_fields :user, Types::UserType
    collection_and_object_by_id_fields :vote, Types::VoteType

    sig { returns(Budget::PrivateRelation) }
    def budgets
      Budget.public_for_api
    end

    sig { params(id: T.any(String, Integer)).returns(Budget) }
    def budget(id:)
      budgets.find(id)
    end

    sig { returns(Comment::PrivateRelation) }
    def comments
      Comment.public_for_api
    end

    sig { params(id: T.any(String, Integer)).returns(Comment) }
    def comment(id:)
      comments.find(id)
    end

    sig { returns(Debate::PrivateRelation) }
    def debates
      Debate.public_for_api
    end

    sig { params(id: T.any(String, Integer)).returns(Debate) }
    def debate(id:)
      debates.find(id)
    end

    sig { returns(Geozone::PrivateRelation) }
    def geozones
      Geozone.public_for_api
    end

    sig { params(id: T.any(String, Integer)).returns(Geozone) }
    def geozone(id:)
      geozones.find(id)
    end

    sig { returns(Milestone::PrivateRelation) }
    def milestones
      Milestone.public_for_api
    end

    sig { params(id: T.any(String, Integer)).returns(Milestone) }
    def milestone(id:)
      milestones.find(id)
    end

    sig { returns(Proposal::PrivateRelation) }
    def proposals
      Proposal.public_for_api
    end

    sig { params(id: T.any(String, Integer)).returns(Proposal) }
    def proposal(id:)
      proposals.find(id)
    end

    sig { returns(ProposalNotification::PrivateRelation) }
    def proposal_notifications
      ProposalNotification.public_for_api
    end

    sig { params(id: T.any(String, Integer)).returns(ProposalNotification) }
    def proposal_notification(id:)
      proposal_notifications.find(id)
    end

    sig { returns(Tag::PrivateRelation) }
    def tags
      Tag.public_for_api
    end

    sig { params(id: T.any(String, Integer)).returns(Tag) }
    def tag(id:)
      tags.find(id)
    end

    sig { returns(User::PrivateRelation) }
    def users
      User.public_for_api
    end

    sig { params(id: T.any(String, Integer)).returns(User) }
    def user(id:)
      users.find(id)
    end

    sig { returns(Vote::PrivateRelation) }
    def votes
      Vote.public_for_api
    end

    sig { params(id: T.any(String, Integer)).returns(Vote) }
    def vote(id:)
      votes.find(id)
    end
  end
end
