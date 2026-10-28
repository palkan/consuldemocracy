# typed: strict
module Abilities
  class Manager
    extend T::Sig
    include CanCan::Ability

    sig { params(user: User).void }
    def initialize(user)
      merge Abilities::Common.new(user)

      can :suggest, Budget::Investment
    end
  end
end
