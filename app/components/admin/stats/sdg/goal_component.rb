# typed: strict
class Admin::Stats::SDG::GoalComponent < ApplicationComponent
  with_collection_parameter :goal

  sig { returns(SDG::Goal) }
  attr_reader :goal

  sig { params(goal: SDG::Goal).void }
  def initialize(goal:)
    @goal = goal
  end

  private

    sig { returns(T::Array[[String, Integer]]) }
    def stats
      [
        [t("admin.stats.sdg.polls"), goal.polls.count],
        [t("admin.stats.sdg.proposals"), goal.proposals.count],
        [t("admin.stats.sdg.debates"), goal.debates.count]
      ]
    end

    sig { returns(T::Array[T::Array[T.untyped]]) }
    def bugdets_stats
      Budget.order(created_at: :desc).map do |budget|
        [
          budget.name,
          [t("admin.stats.sdg.budget_investments.sent"), sent(budget)],
          [t("admin.stats.sdg.budget_investments.winners"), winners(budget), featured],
          [t("admin.stats.sdg.budget_investments.amount"), amount(budget), featured]
        ]
      end
    end

    sig { params(budget: Budget).returns(Integer) }
    def sent(budget)
      investments(budget).count
    end

    sig { params(budget: Budget).returns(Integer) }
    def winners(budget)
      investments(budget).winners.count
    end

    sig { params(budget: Budget).returns(T.nilable(String)) }
    def amount(budget)
      number_to_currency(investments(budget).winners.sum(:price), precision: 0)
    end

    sig { params(budget: Budget).returns(Budget::Investment::PrivateAssociationRelation) }
    def investments(budget)
      T.cast(goal.budget_investments, Budget::Investment::PrivateCollectionProxy).by_budget(budget)
    end

    sig { returns(T::Hash[Symbol, String]) }
    def featured
      { class: "featured" }
    end
end
