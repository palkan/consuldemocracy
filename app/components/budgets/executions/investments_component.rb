# typed: strict
class Budgets::Executions::InvestmentsComponent < ApplicationComponent
  sig { returns(T::Hash[T.nilable(Budget::Heading), T::Array[Budget::Investment]]) }
  attr_reader :investments_by_heading

  sig do
    params(investments_by_heading: T::Hash[T.nilable(Budget::Heading), T::Array[Budget::Investment]]).void
  end
  def initialize(investments_by_heading)
    @investments_by_heading = investments_by_heading
  end
end
