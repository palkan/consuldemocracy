# typed: strict
class Admin::BudgetPhases::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper
  include Admin::Namespace

  sig { returns(Budget::Phase) }
  attr_reader :phase

  sig { params(phase: Budget::Phase).void }
  def initialize(phase)
    @phase = phase
  end
end
