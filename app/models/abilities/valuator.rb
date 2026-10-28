# typed: strict
module Abilities
  class Valuator
    extend T::Sig
    include CanCan::Ability

    sig { params(user: User).void }
    def initialize(user)
      valuator = T.must(user.valuator)
      assigned_investment_ids = valuator.assigned_investment_ids

      can [:read], Budget::Investment, id: assigned_investment_ids

      if valuator.can_edit_dossier?
        can [:valuate], Budget::Investment, { id: assigned_investment_ids, valuation_finished: false }
      end

      if valuator.can_comment?
        can [:comment_valuation], Budget::Investment, id: assigned_investment_ids
      end

      cannot [:valuate, :comment_valuation], Budget::Investment, budget: { phase: "finished" }
    end
  end
end
