# typed: strict
module Abilities
  class Moderator
    extend T::Sig
    include CanCan::Ability

    sig { params(user: User).void }
    def initialize(user)
      merge Abilities::Moderation.new(user)

      can :comment_as_moderator, [Debate, Comment, Proposal, Budget::Investment, Poll,
                                  Poll::Question, Legislation::Question,
                                  Legislation::Annotation, Legislation::Proposal, Topic]
    end
  end
end
