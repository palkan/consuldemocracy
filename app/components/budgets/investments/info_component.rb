# typed: strict
class Budgets::Investments::InfoComponent < ApplicationComponent
  sig { returns(Budget::Investment) }
  attr_reader :investment

  sig { params(investment: Budget::Investment).void }
  def initialize(investment)
    @investment = investment
  end
end
