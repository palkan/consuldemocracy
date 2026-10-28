# typed: strict
class Admin::VotationTypes::FieldsComponent < ApplicationComponent
  sig { returns(ActionView::Helpers::FormBuilder) }
  attr_reader :form

  sig { params(form: ActionView::Helpers::FormBuilder).void }
  def initialize(form:)
    @form = form
  end

  private

    sig { returns(T::Hash[Symbol, String]) }
    def descriptions
      {
        unique: t("admin.polls.votation_type.unique_description"),
        multiple: t("admin.polls.votation_type.multiple_description"),
        open: t("admin.polls.votation_type.open_description")
      }
    end

    sig { params(vote_type: Symbol, text: String).returns(ActiveSupport::SafeBuffer) }
    def description_tag(vote_type, text)
      tag.span(text, data: { vote_type: vote_type })
    end
end
