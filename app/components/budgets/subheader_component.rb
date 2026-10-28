# typed: strict
class Budgets::SubheaderComponent < ApplicationComponent
  delegate :link_to_signin, :link_to_signup, :link_to_verify_account, to: :helpers

  sig { returns(Budget) }
  attr_reader :budget

  sig { params(budget: Budget).void }
  def initialize(budget)
    @budget = budget
  end
end
