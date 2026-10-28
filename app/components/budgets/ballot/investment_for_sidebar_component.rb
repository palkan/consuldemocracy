# typed: strict
class Budgets::Ballot::InvestmentForSidebarComponent < Budgets::Ballot::InvestmentComponent
  with_collection_parameter :investment

  sig { returns(T.nilable(T::Array[T.any(Integer, String)])) }
  attr_reader :investment_ids

  sig do
    params(investment: Budget::Investment, investment_ids: T.nilable(T::Array[T.any(Integer, String)])).void
  end
  def initialize(investment:, investment_ids:)
    super(investment: investment)
    @investment_ids = investment_ids
  end

  private

    sig { returns(String) }
    def list_item_id
      "#{super}_sidebar"
    end

    sig { returns(ActiveSupport::SafeBuffer) }
    def investment_title
      tag.span investment.title, class: "ballot-list-title"
    end

    sig { returns(String) }
    def delete_path
      budget_ballot_line_path(budget, id: investment.id, investments_ids: investment_ids)
    end
end
