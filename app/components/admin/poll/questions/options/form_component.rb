# typed: strict
class Admin::Poll::Questions::Options::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  sig { returns(::Poll::Question::Option) }
  attr_reader :option

  sig { returns(String) }
  attr_reader :url

  sig { params(option: ::Poll::Question::Option, url: String).void }
  def initialize(option, url:)
    @option = option
    @url = url
  end

  private

    sig { params(form: ActionView::Helpers::FormBuilder).returns(String) }
    def allow_custom_text_help_id(form)
      form.field_id(:allow_custom_text, :help)
    end
end
