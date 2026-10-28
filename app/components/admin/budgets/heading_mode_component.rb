# typed: strict
class Admin::Budgets::HeadingModeComponent < ApplicationComponent
  private

    sig { returns(String) }
    def i18n_namespace
      "admin.budgets_wizard.heading_mode"
    end

    sig { returns(T::Array[String]) }
    def modes
      %w[single multiple]
    end
end
