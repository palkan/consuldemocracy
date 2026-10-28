# typed: strict
class Admin::BudgetsWizard::BaseComponent < ApplicationComponent
  delegate :single_heading?, :url_params, to: :helpers

  sig { returns(String) }
  def budget_mode
    helpers.budget_mode || "multiple"
  end
end
