# typed: strict
class Budgets::Ballot::InvestmentComponent < ApplicationComponent
  sig { returns(Budget::Investment) }
  attr_reader :investment

  sig { params(investment: Budget::Investment).void }
  def initialize(investment:)
    @investment = investment
  end

  private

    sig { returns(Budget) }
    def budget
      T.must(investment.budget)
    end

    sig { returns(String) }
    def list_item_id
      dom_id(investment)
    end

    sig { returns(ActiveSupport::SafeBuffer) }
    def investment_title
      link_to investment.title, budget_investment_path(budget, investment)
    end

    sig { returns(T.nilable(ActiveSupport::SafeBuffer)) }
    def investment_price
      tag.span investment.formatted_price, class: "ballot-list-price" if budget.show_money?
    end

    sig { returns(String) }
    def delete_path
      budget_ballot_line_path(budget, id: investment.id)
    end
end
