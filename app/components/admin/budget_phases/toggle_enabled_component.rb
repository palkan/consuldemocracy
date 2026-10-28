# typed: strict
class Admin::BudgetPhases::ToggleEnabledComponent < ApplicationComponent
  sig { returns(Budget::Phase) }
  attr_reader :phase

  delegate :enabled?, to: :phase

  sig { params(phase: Budget::Phase).void }
  def initialize(phase)
    @phase = phase
  end

  private

    sig { returns(T::Hash[Symbol, String]) }
    def options
      { "aria-label": t("admin.budgets.edit.enable_phase", phase: phase.name) }
    end

    sig { returns(Symbol) }
    def action
      if enabled?
        :disable
      else
        :enable
      end
    end
end
