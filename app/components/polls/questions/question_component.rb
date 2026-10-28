# typed: strict
class Polls::Questions::QuestionComponent < ApplicationComponent
  sig { returns(Poll::Question) }
  attr_reader :question

  sig { returns(ConsulFormBuilder) }
  attr_reader :form

  sig { returns(T::Boolean) }
  attr_reader :disabled

  alias_method :disabled?, :disabled

  sig { params(question: Poll::Question, form: ConsulFormBuilder, disabled: T::Boolean).void }
  def initialize(question, form:, disabled: false)
    @question = question
    @form = form
    @disabled = disabled
  end

  private

    sig { returns(ActiveSupport::SafeBuffer) }
    def fieldset_attributes
      tag.attributes(
        id: dom_id(question),
        disabled: ("disabled" if disabled?),
        class: fieldset_class,
        data: { max_votes: question.max_votes },
        aria: {
          labelledby: [
            dom_id(question, :legend),
            (dom_id(question, :help_text) if multiple_choice?),
            (form.field_id(:"question_#{question.id}", :error) if error.present?)
          ]
        }
      )
    end

    sig { returns(String) }
    def fieldset_class
      if multiple_choice?
        "multiple-choice"
      else
        "single-choice"
      end
    end

    sig { returns(ActiveSupport::SafeBuffer) }
    def options_read_more_links
      safe_join(question.options_with_read_more.map do |option|
        link_to option.title, "#option_#{option.id}"
      end, ", ")
    end

    sig { returns(T::Enumerable[Poll::Answer]) }
    def answers_for_question
      form.object.answers[question.id] || []
    end

    sig { returns(T.nilable(String)) }
    def existing_answer
      answers_for_question.first&.answer
    end

    sig { returns(T.nilable(T::Boolean)) }
    def multiple_choice?
      question.multiple?
    end

    sig { returns(ActiveSupport::SafeBuffer) }
    def multiple_choice_help_text
      tag.span(
        t("poll_questions.description.multiple", maximum: question.max_votes),
        class: "help-text",
        id: dom_id(question, :help_text)
      )
    end

    sig { params(option: Poll::Question::Option).returns(ActiveSupport::SafeBuffer) }
    def choice_field(option)
      safe_join([
        option_label_with_input(option),
        (open_text_tag(option) if option.allow_custom_text?)
      ])
    end

    sig { params(option: Poll::Question::Option).returns(ActiveSupport::SafeBuffer) }
    def option_label_with_input(option)
      label_tag("web_vote_option_#{option.id}") do
        input_tag(option) + option.title
      end
    end

    sig { params(option: Poll::Question::Option).returns(ActiveSupport::SafeBuffer) }
    def input_tag(option)
      if multiple_choice?
        check_box_tag "web_vote[#{question.id}][option_id][]",
                      option.id,
                      checked?(option),
                      id: "web_vote_option_#{option.id}"
      else
        radio_button_tag "web_vote[#{question.id}][option_id]",
                         option.id,
                         checked?(option),
                         id: "web_vote_option_#{option.id}"
      end
    end

    sig { params(option: Poll::Question::Option).returns(ActiveSupport::SafeBuffer) }
    def open_text_tag(option)
      text_area_tag(
        "web_vote[#{question.id}][answer][#{option.id}]",
        existing_text_for(option),
        id: "web_vote_option_#{option.id}_answer",
        class: "custom-answer",
        maxlength: Poll::Answer.answer_max_length,
        rows: 1,
        "aria-label": t("poll_questions.custom_answer_aria_label", option: option.title),
        data: { selects: "web_vote_option_#{option.id}" }
      )
    end

    sig { params(option: Poll::Question::Option).returns(String) }
    def existing_text_for(option)
      answer_for(option)&.answer.to_s
    end

    sig { params(option: Poll::Question::Option).returns(T::Boolean) }
    def checked?(option)
      answer_for(option).present?
    end

    sig { params(option: Poll::Question::Option).returns(T.nilable(Poll::Answer)) }
    def answer_for(option)
      answers_for_question.find { |answer| answer.option_id == option.id }
    end

    sig { returns(T.nilable(ActiveSupport::SafeBuffer)) }
    def error
      form.error_for(:"question_#{question.id}")
    end
end
