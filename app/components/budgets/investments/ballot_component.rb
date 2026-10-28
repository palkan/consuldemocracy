# typed: strict
class Budgets::Investments::BallotComponent < ApplicationComponent
  sig { returns(Budget::Investment) }
  attr_reader :investment

  sig { returns(T.nilable(T::Array[T.any(Integer, String)])) }
  attr_reader :investment_ids

  sig { returns(Budget::Ballot) }
  attr_reader :ballot

  delegate :heading_link, :link_to_verify_account, to: :helpers

  sig do
    params(
      investment: Budget::Investment,
      investment_ids: T.nilable(T::Array[T.any(Integer, String)]),
      ballot: Budget::Ballot
    ).void
  end
  def initialize(investment:, investment_ids:, ballot:)
    @investment = investment
    @investment_ids = investment_ids
    @ballot = ballot
    @reason = T.let(nil, T.nilable(Symbol))
  end

  private

    sig { returns(Budget) }
    def budget
      T.must(ballot.budget)
    end

    sig { returns(T::Boolean) }
    def voted?
      ballot.has_investment?(investment)
    end

    sig { returns(T.nilable(Symbol)) }
    def reason
      @reason ||= investment.reason_for_not_being_ballotable_by(current_user, ballot)
    end

    sig { returns(String) }
    def vote_aria_label
      t("budgets.investments.investment.add_label", investment: investment.title)
    end

    sig { returns(String) }
    def remove_vote_aria_label
      t("budgets.ballots.show.remove_label", investment: investment.title)
    end

    sig { returns(ActiveSupport::SafeBuffer) }
    def link_to_my_heading
      link_to(T.must(investment.heading).name,
              budget_investments_path(budget_id: investment.budget_id,
                                      heading_id: investment.heading_id))
    end

    sig { returns(ActiveSupport::SafeBuffer) }
    def link_to_change_ballot
      link_to(t("budgets.ballots.reasons_for_not_balloting.change_ballot"),
              budget_ballot_path(budget))
    end

    sig { returns(T.nilable(Budget::Heading)) }
    def assigned_heading
      ballot.heading_for_group(investment.group)
    end

    sig { returns(T.nilable(String)) }
    def cannot_vote_text
      if reason.present? && !voted?
        t("budgets.ballots.reasons_for_not_balloting.#{reason}",
          verify_account: link_to_verify_account,
          my_heading: link_to_my_heading,
          change_ballot: link_to_change_ballot,
          heading_link: heading_link(assigned_heading, budget))
      end
    end
end
