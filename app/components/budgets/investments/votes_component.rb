# typed: strict
class Budgets::Investments::VotesComponent < ApplicationComponent
  sig { returns(Budget::Investment) }
  attr_reader :investment

  delegate :namespace, :image_absolute_url, :link_to_verify_account, to: :helpers

  sig { params(investment: Budget::Investment).void }
  def initialize(investment)
    @investment = investment
    @reason = T.let(nil, T.nilable(Symbol))
  end

  sig { returns(String) }
  def support_path
    case namespace
    when "management"
      management_budget_investment_votes_path(investment.budget, investment)
    else
      budget_investment_votes_path(investment.budget, investment)
    end
  end

  sig { returns(String) }
  def remove_support_path
    vote = investment.votes_for.find_by!(voter: current_user)

    case namespace
    when "management"
      management_budget_investment_vote_path(investment.budget, investment, vote)
    else
      budget_investment_vote_path(investment.budget, investment, vote)
    end
  end

  private

    sig { returns(T.nilable(Symbol)) }
    def reason
      @reason ||= investment.reason_for_not_being_selectable_by(current_user)
    end

    sig { returns(T::Boolean) }
    def voting_allowed?
      reason != :not_voting_allowed
    end

    sig { returns(T.nilable(T::Boolean)) }
    def user_voted_for?
      unless defined?(@user_voted_for)
        @user_voted_for = T.let(current_user&.voted_for?(investment), T.nilable(T::Boolean))
      end
      @user_voted_for
    end

    sig { returns(T.nilable(T::Boolean)) }
    def display_support_alert?
      user = current_user
      return unless user

      group = T.must(investment.group)
      !user.voted_in_group?(group) && group.headings.count > T.must(group.max_votable_headings)
    end

    sig { returns(String) }
    def confirm_vote_message
      t("budgets.investments.votes.confirm_group", count: T.must(investment.group).max_votable_headings)
    end

    sig { returns(String) }
    def support_aria_label
      t("budgets.investments.votes.support_label", investment: investment.title)
    end

    sig { returns(String) }
    def remove_support_aria_label
      t("budgets.investments.votes.remove_support_label", investment: investment.title)
    end

    sig { returns(T.nilable(String)) }
    def cannot_vote_text
      if reason.present? && !user_voted_for?
        t("votes.budget_investments.#{reason}",
          count: T.must(investment.group).max_votable_headings,
          verify_account: link_to_verify_account,
          supported_headings: supported_headings)
      end
    end

    sig { returns(T.nilable(String)) }
    def supported_headings
      user = current_user
      user && user.headings_voted_within_group(T.must(investment.group))
                  .map(&:name)
                  .sort
                  .to_sentence
    end
end
