# typed: strict
class Admin::Budgets::ShowComponent < ApplicationComponent
  include Header

  sig { returns(Budget) }
  attr_reader :budget

  sig { params(budget: Budget).void }
  def initialize(budget)
    @budget = budget
  end

  private

    sig { override.returns(T.nilable(String)) }
    def title
      budget.name
    end
end
