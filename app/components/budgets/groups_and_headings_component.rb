# typed: strict
class Budgets::GroupsAndHeadingsComponent < ApplicationComponent
  sig { returns(Budget) }
  attr_reader :budget

  sig { params(budget: Budget).void }
  def initialize(budget)
    @budget = budget
  end

  private

    sig { params(heading: Budget::Heading).returns(T.nilable(ActiveSupport::SafeBuffer)) }
    def price(heading)
      tag.span(budget.formatted_heading_price(heading)) if budget.show_money?
    end
end
