# typed: strict
class Admin::BudgetsWizard::CreationStepComponent < Admin::BudgetsWizard::BaseComponent
  sig { returns(T.any(Budget::Group, Budget::Heading)) }
  attr_reader :record

  sig { returns(T.nilable(String)) }
  attr_reader :next_step_path

  sig { params(record: T.any(Budget::Group, Budget::Heading), next_step_path: T.nilable(String)).void }
  def initialize(record, next_step_path)
    @record = record
    @next_step_path = next_step_path
  end

  private

    sig { returns(T::Boolean) }
    def show_form?
      record.errors.any?
    end

    sig { returns(String) }
    def i18n_namespace
      i18n_namespace_with_budget.gsub("budget_", "")
    end

    sig { returns(String) }
    def i18n_namespace_with_budget
      record.class.table_name
    end
end
