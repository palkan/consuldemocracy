# typed: strict
class Budget::VotingStyles::Knapsack < Budget::VotingStyles::Base
  sig { override.params(investment: Budget::Investment).returns(T::Boolean) }
  def enough_resources?(investment)
    investment.price.to_i <= amount_available(T.must(investment.heading))
  end

  sig { override.params(investment: Budget::Investment).returns(T.nilable(Symbol)) }
  def reason_for_not_being_ballotable(investment)
    :not_enough_money unless enough_resources?(investment)
  end

  sig { override.returns(String) }
  def not_enough_resources_error
    "insufficient funds"
  end

  sig { override.params(heading: Budget::Heading).returns(Integer) }
  def amount_spent(heading)
    investments_price(heading)
  end

  sig { override.params(heading: Budget::Heading).returns(Integer) }
  def amount_limit(heading)
    T.must(budget.heading_price(heading))
  end

  sig { override.params(amount: Integer).returns(T.nilable(String)) }
  def format(amount)
    budget.formatted_amount(amount)
  end
end
