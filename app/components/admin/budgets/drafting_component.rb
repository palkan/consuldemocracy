# typed: strict
class Admin::Budgets::DraftingComponent < ApplicationComponent
  sig { returns(Budget) }
  attr_reader :budget

  sig { params(budget: Budget).void }
  def initialize(budget)
    @budget = budget
  end

  sig { returns(T::Boolean) }
  def render?
    can?(:publish, budget)
  end
end
