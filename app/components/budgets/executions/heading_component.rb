# typed: strict
class Budgets::Executions::HeadingComponent < ApplicationComponent
  sig { returns(Budget::Heading) }
  attr_reader :heading

  sig { returns(T::Array[Budget::Investment]) }
  attr_reader :investments

  sig { params(heading: Budget::Heading, investments: T::Array[Budget::Investment]).void }
  def initialize(heading, investments)
    @heading = heading
    @investments = investments
  end
end
