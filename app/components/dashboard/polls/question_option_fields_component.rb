# typed: strict
class Dashboard::Polls::QuestionOptionFieldsComponent < ApplicationComponent
  sig { returns(ActionView::Helpers::FormBuilder) }
  attr_reader :form

  sig { params(form: ActionView::Helpers::FormBuilder).void }
  def initialize(form)
    @form = form
  end
end
