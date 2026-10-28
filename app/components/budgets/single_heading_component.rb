# typed: strict
class Budgets::SingleHeadingComponent < ApplicationComponent
  sig { returns(Budget) }
  attr_reader :budget

  sig { params(budget: Budget).void }
  def initialize(budget)
    @budget = budget
  end

  private

    sig { returns(Budget::Heading) }
    def heading
      T.must(budget.headings.first)
    end

    sig { returns(String) }
    def title
      heading.name
    end

    sig { returns(T.nilable(ActiveSupport::SafeBuffer)) }
    def price
      tag.p budget.formatted_heading_price(heading) if budget.show_money?
    end
end
