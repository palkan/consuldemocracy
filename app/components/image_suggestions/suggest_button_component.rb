# typed: strict
class ImageSuggestions::SuggestButtonComponent < ApplicationComponent
  sig { returns(ActionView::Helpers::FormBuilder) }
  attr_reader :form

  sig { params(form: ActionView::Helpers::FormBuilder).void }
  def initialize(form)
    @form = form
  end

  sig { returns(T.nilable(T::Boolean)) }
  def render?
    ::Llm::Config.configured? && Setting["llm.use_ai_image_suggestions"].present?
  end

  private

    sig { returns(String) }
    def resource_type
      form.object.class.name
    end

    sig { returns(T.nilable(Integer)) }
    def resource_id
      form.object.id if form.object.persisted?
    end
end
