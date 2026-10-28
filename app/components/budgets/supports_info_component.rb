# typed: strict
class Budgets::SupportsInfoComponent < ApplicationComponent
  sig { returns(Budget) }
  attr_reader :budget

  sig { params(budget: Budget).void }
  def initialize(budget)
    @budget = budget
  end

  sig { returns(T::Boolean) }
  def render?
    budget.selecting?
  end

  private

    sig { returns(T.nilable(ActiveSupport::SafeBuffer)) }
    def support_info_heading
      if current_user
        sanitize(t("budgets.supports_info.supported", count: total_supports))
      else
        sanitize(t("budgets.supports_info.supported_not_logged_in"))
      end
    end

    sig { returns(Integer) }
    def total_supports
      Vote.where(votable: budget.investments, voter: current_user).count
    end
end
