# typed: strict
class Admin::Budgets::GroupsAndHeadingsComponent < ApplicationComponent
  sig { returns(Budget) }
  attr_reader :budget

  sig { params(budget: Budget).void }
  def initialize(budget)
    @budget = budget
  end

  private

    sig do
      params(action_name: Symbol, record: T.any(Budget, Budget::Group), "**": T.untyped)
        .returns(ActiveSupport::SafeBuffer)
    end
    def action(action_name, record, **)
      render Admin::ActionComponent.new(action_name, record, **)
    end
end
