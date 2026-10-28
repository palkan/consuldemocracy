# typed: strict
class Admin::Budgets::HelpComponent < ApplicationComponent
  sig { returns(String) }
  attr_reader :i18n_namespace

  sig { params(i18n_namespace: String).void }
  def initialize(i18n_namespace)
    @i18n_namespace = i18n_namespace
  end

  sig { returns(String) }
  def budget_mode
    (helpers.budget_mode if helpers.respond_to?(:budget_mode)).presence || "multiple"
  end

  private

    sig { returns(String) }
    def text
      if t("admin.budgets.help.#{i18n_namespace}").is_a?(Hash)
        t("admin.budgets.help.#{i18n_namespace}.#{budget_mode}")
      else
        t("admin.budgets.help.#{i18n_namespace}")
      end
    end
end
