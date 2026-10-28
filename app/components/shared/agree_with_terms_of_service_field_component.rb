# typed: strict
class Shared::AgreeWithTermsOfServiceFieldComponent < ApplicationComponent
  sig { returns(ActionView::Helpers::FormBuilder) }
  attr_reader :form

  delegate :new_window_link_to, to: :helpers

  sig { params(form: ActionView::Helpers::FormBuilder).void }
  def initialize(form)
    @form = form
  end

  private

    sig { returns(String) }
    def label
      t("form.accept_terms",
        policy: new_window_link_to(t("form.policy"), "/privacy"),
        conditions: new_window_link_to(t("form.conditions"), "/conditions"))
    end
end
