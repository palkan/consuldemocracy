# typed: strict
class Budgets::PhasesComponent < ApplicationComponent
  delegate :wysiwyg, :auto_link_already_sanitized_html, to: :helpers

  sig { returns(Budget) }
  attr_reader :budget

  sig { params(budget: Budget).void }
  def initialize(budget)
    @budget = budget
  end

  private

    sig { returns(Budget::Phase::PrivateAssociationRelation) }
    def phases
      budget.published_phases
    end

    sig { params(phase: Budget::Phase).returns(T.nilable(ActiveSupport::SafeBuffer)) }
    def start_date(phase)
      time_tag(T.must(phase.starts_at).to_date, format: :long) if phase.starts_at.present?
    end

    sig { params(phase: Budget::Phase).returns(T.nilable(ActiveSupport::SafeBuffer)) }
    def end_date(phase)
      time_tag(T.must(phase.ends_at).to_date - 1.day, format: :long) if phase.ends_at.present?
    end

    sig { params(phase: Budget::Phase).returns(String) }
    def phase_dom_id(phase)
      "phase-#{phases.index(phase) + 1}-#{phase.name.parameterize}"
    end

    sig { params(phase: Budget::Phase).returns(String) }
    def prev_phase_dom_id(phase)
      phase_dom_id(phases[phases.index(phase) - 1])
    end

    sig { params(phase: Budget::Phase).returns(String) }
    def next_phase_dom_id(phase)
      phase_dom_id(phases[phases.index(phase) + 1])
    end
end
