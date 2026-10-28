# typed: strict
class Dashboard::Polls::QuestionFieldsComponent < ApplicationComponent
  sig { returns(ActionView::Helpers::FormBuilder) }
  attr_reader :form

  sig { params(form: ActionView::Helpers::FormBuilder).void }
  def initialize(form)
    @form = form
  end

  private

    sig { returns(Poll::Question) }
    def question
      form.object
    end

    sig { returns(Proposal) }
    def proposal
      question.proposal || T.must(question.poll).related
    end
end
