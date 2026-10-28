# typed: strict
class Admin::Budgets::IndexComponent < ApplicationComponent
  include Header

  sig { returns(Budget::PrivateRelation) }
  attr_reader :budgets

  sig { params(budgets: Budget::PrivateRelation).void }
  def initialize(budgets)
    @budgets = budgets
  end

  sig { override.returns(String) }
  def title
    t("admin.budgets.index.title")
  end

  private

    sig { params(budget: Budget).returns(String) }
    def phase_progress_text(budget)
      t("admin.budgets.index.table_phase_progress",
        current_phase_number: current_enabled_phase_number(budget),
        total_phases: budget.phases.enabled.count)
    end

    sig { params(budget: Budget).returns(Integer) }
    def current_enabled_phase_number(budget)
      current_enabled_phase_index(budget) + 1
    end

    sig { params(budget: Budget).returns(Integer) }
    def current_enabled_phase_index(budget)
      budget.phases.enabled.order(:id).pluck(:kind).index(budget.phase) || -1
    end

    sig { params(budget: Budget).returns(String) }
    def type(budget)
      if budget.single_heading?
        t("admin.budgets.index.type_single")
      elsif budget.headings.blank?
        t("admin.budgets.index.type_pending")
      else
        t("admin.budgets.index.type_multiple")
      end
    end

    sig { params(budget: Budget).returns(ActiveSupport::SafeBuffer) }
    def dates(budget)
      render Admin::DurationComponent.new(budget)
    end

    sig { params(budget: Budget).returns(ActiveSupport::SafeBuffer) }
    def duration(budget)
      render Admin::Budgets::DurationInWordsComponent.new(budget)
    end

    sig { params(budget: Budget).returns(T.nilable(String)) }
    def status_html_class(budget)
      if budget.drafting?
        "budget-draft"
      elsif budget.finished?
        "budget-completed"
      end
    end

    sig { params(budget: Budget).returns(T.nilable(ActiveSupport::SafeBuffer)) }
    def status_text(budget)
      if budget.drafting?
        tag.span t("admin.budgets.index.table_draft")
      elsif budget.finished?
        tag.span t("admin.budgets.index.table_completed")
      end
    end
end
