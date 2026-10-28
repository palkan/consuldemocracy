# typed: strict
class Budgets::Investments::NewComponent < ApplicationComponent
  include Header

  sig { returns(Budget) }
  attr_reader :budget

  sig { params(budget: Budget).void }
  def initialize(budget)
    @budget = budget
  end

  sig { override.returns(ActiveSupport::SafeBuffer) }
  def title
    safe_join([base_title, subtitle].compact, " ")
  end

  private

    sig { returns(T.nilable(ActiveSupport::SafeBuffer)) }
    def base_title
      sanitize(t("budgets.investments.form.title"))
    end

    sig { returns(T.nilable(ActiveSupport::SafeBuffer)) }
    def subtitle
      return unless budget.single_heading?

      heading = T.must(budget.headings.first)

      if budget.show_money?
        tag.span t("budgets.investments.form.subtitle",
                   heading: heading.name,
                   price: budget.formatted_heading_price(heading))
      else
        tag.span t("budgets.investments.form.subtitle_without_price", heading: heading.name)
      end
    end
end
