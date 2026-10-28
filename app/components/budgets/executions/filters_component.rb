# typed: strict
class Budgets::Executions::FiltersComponent < ApplicationComponent
  sig { returns(Budget) }
  attr_reader :budget

  sig { returns(T::Enumerable[Milestone::Status]) }
  attr_reader :statuses

  sig { params(budget: Budget, statuses: T::Enumerable[Milestone::Status]).void }
  def initialize(budget, statuses)
    @budget = budget
    @statuses = statuses
  end

  sig { returns(T::Array[[String, String]]) }
  def options_for_milestone_tags
    budget.investments_milestone_tags.map do |tag|
      ["#{tag} (#{budget.investments.winners.by_tag(tag).count})", tag]
    end
  end

  private

    sig { params(status: Integer).returns(Integer) }
    def filters_select_counts(status)
      budget.investments.winners.with_milestone_status_id(status).count
    end
end
