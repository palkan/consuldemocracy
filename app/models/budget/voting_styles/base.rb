# typed: strict
class Budget::VotingStyles::Base
  extend T::Sig
  extend T::Helpers

  abstract!

  sig { returns(Budget::Ballot) }
  attr_reader :ballot

  sig { params(ballot: Budget::Ballot).void }
  def initialize(ballot)
    @ballot = ballot
  end

  sig { abstract.params(investment: Budget::Investment).returns(T::Boolean) }
  def enough_resources?(investment); end

  sig { abstract.params(investment: Budget::Investment).returns(T.nilable(Symbol)) }
  def reason_for_not_being_ballotable(investment); end

  sig { abstract.returns(String) }
  def not_enough_resources_error; end

  sig { abstract.params(heading: Budget::Heading).returns(Integer) }
  def amount_spent(heading); end

  sig { abstract.params(heading: Budget::Heading).returns(Integer) }
  def amount_limit(heading); end

  sig { abstract.params(amount: Integer).returns(T.nilable(T.any(Integer, String))) }
  def format(amount); end

  sig { returns(String) }
  def name
    T.must(T.must(self.class.name).split("::").last).underscore
  end

  sig { params(link: String).returns(String) }
  def change_vote_info(link:)
    I18n.t(
      "budgets.investments.index.sidebar.change_vote_info.#{name}",
      link: link,
      phase_end_date: I18n.l(T.must(T.must(budget.current_phase).ends_at).to_date, format: :long)
    )
  end

  sig { params(heading: Budget::Heading).returns(String) }
  def amount_progress(heading)
    I18n.t(
      "budgets.ballots.show.amount_progress",
      amount_spent: amount_spent_info(heading),
      amount_limit: amount_limit_info(heading)
    )
  end

  sig { params(heading: Budget::Heading).returns(String) }
  def voted_info(heading)
    I18n.t("budgets.investments.index.sidebar.voted_info.#{name}",
           count: investments(heading).count,
           amount_spent: budget.formatted_amount(investments_price(heading)))
  end

  sig { params(heading: Budget::Heading).returns(String) }
  def amount_available_info(heading)
    I18n.t("budgets.ballots.show.amount_available.#{name}",
           count: formatted_amount_available(heading))
  end

  sig { params(heading: Budget::Heading).returns(String) }
  def amount_spent_info(heading)
    I18n.t("budgets.ballots.show.amount_spent.#{name}",
           count: formatted_amount_spent(heading))
  end

  sig { params(heading: Budget::Heading).returns(String) }
  def amount_limit_info(heading)
    I18n.t("budgets.ballots.show.amount_limit.#{name}",
           count: formatted_amount_limit(heading))
  end

  sig { params(heading: Budget::Heading).returns(Integer) }
  def amount_available(heading)
    amount_limit(heading) - amount_spent(heading)
  end

  sig { params(heading: Budget::Heading).returns(Float) }
  def percentage_spent(heading)
    100.0 * amount_spent(heading) / amount_limit(heading)
  end

  sig { params(heading: Budget::Heading).returns(T.nilable(T.any(Integer, String))) }
  def formatted_amount_available(heading)
    format(amount_available(heading))
  end

  sig { params(heading: Budget::Heading).returns(T.nilable(T.any(Integer, String))) }
  def formatted_amount_spent(heading)
    format(amount_spent(heading))
  end

  sig { params(heading: Budget::Heading).returns(T.nilable(T.any(Integer, String))) }
  def formatted_amount_limit(heading)
    format(amount_limit(heading))
  end

  private

    sig { returns(Budget) }
    def budget
      T.must(ballot.budget)
    end

    sig { params(heading: Budget::Heading).returns(Budget::Investment::PrivateAssociationRelation) }
    def investments(heading)
      ballot.investments.by_heading(heading.id)
    end

    sig { params(heading: Budget::Heading).returns(Integer) }
    def investments_price(heading)
      investments(heading).sum(:price).to_i
    end
end
