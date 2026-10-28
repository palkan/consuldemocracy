# typed: strict
class Budgets::Groups::IndexComponent < ApplicationComponent
  include Header

  sig { returns(Budget) }
  attr_reader :budget

  sig { params(budget: Budget).void }
  def initialize(budget)
    @budget = budget
  end

  sig { override.returns(String) }
  def title
    t("budgets.groups.show.title")
  end
end
