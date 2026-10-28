# typed: strict
class Budget::VotingStyles::Approval < Budget::VotingStyles::Base
  sig { override.params(investment: Budget::Investment).returns(T::Boolean) }
  def enough_resources?(investment)
    amount_available(T.must(investment.heading)) > 0
  end

  sig { override.params(investment: Budget::Investment).returns(T.nilable(Symbol)) }
  def reason_for_not_being_ballotable(investment)
    :not_enough_available_votes unless enough_resources?(investment)
  end

  sig { override.returns(String) }
  def not_enough_resources_error
    "insufficient votes"
  end

  sig { override.params(heading: Budget::Heading).returns(Integer) }
  def amount_spent(heading)
    investments(heading).count
  end

  sig { override.params(heading: Budget::Heading).returns(Integer) }
  def amount_limit(heading)
    T.must(heading.max_ballot_lines)
  end

  sig { override.params(amount: Integer).returns(Integer) }
  def format(amount)
    amount
  end
end
