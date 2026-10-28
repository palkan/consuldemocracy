# typed: strict
class ConsulFormBuilder < FoundationRailsHelper::FormBuilder
  extend T::Sig
  include ActionView::Helpers::SanitizeHelper

  sig do
    params(
      attribute: T.any(String, Symbol),
      options: T::Hash[Symbol, T.untyped],
      html_options: T::Hash[Symbol, T.untyped]
    ).returns(ActiveSupport::SafeBuffer)
  end
  def enum_select(attribute, options = {}, html_options = {})
    choices = object.class.send(attribute.to_s.pluralize).keys.map do |name|
      [object.class.human_attribute_name("#{attribute}.#{name}"), name]
    end

    select attribute, choices, options, html_options
  end

  %i[text_field text_area date_field number_field password_field email_field].each do |field|
    define_method field do |attribute, options = {}|
      T.bind(self, ConsulFormBuilder)

      label_with_hint(attribute, options.merge(label_options: label_options_for(options))) +
        super(attribute, options.merge(
          label: false, hint: nil,
          aria: { describedby: help_text_id(attribute, options) }
        ))
    end
  end

  sig do
    params(
      attribute: T.any(String, Symbol),
      options: T::Hash[Symbol, T.untyped]
    ).returns(ActiveSupport::SafeBuffer)
  end
  def check_box(attribute, options = {})
    options_with_aria_error = aria_error_options(attribute).merge(options)

    if options[:label] == false
      super(attribute, options_with_aria_error)
    else
      label = tag.span sanitized_label_text(attribute, options[:label]), class: "checkbox"

      super(attribute, options_with_aria_error.merge(
        label: label,
        label_options: { class: "checkbox-label" }.merge(label_options_for(options))
      ))
    end
  end

  sig do
    params(
      attribute: T.any(String, Symbol),
      tag_value: T.untyped,
      options: T::Hash[Symbol, T.untyped]
    ).returns(ActiveSupport::SafeBuffer)
  end
  def radio_button(attribute, tag_value, options = {})
    default_label = object.class.human_attribute_name("#{attribute}_#{tag_value}")

    super(attribute, tag_value, { label: default_label }.merge(options))
  end

  sig do
    params(
      attribute: T.any(String, Symbol),
      choices: T.untyped,
      options: T::Hash[Symbol, T.untyped],
      html_options: T::Hash[T.any(String, Symbol), T.untyped]
    ).returns(ActiveSupport::SafeBuffer)
  end
  def select(attribute, choices, options = {}, html_options = {})
    label_with_hint(attribute, options.merge(label_options: label_options_for(options))) +
      super(attribute, choices, options.merge(label: false, hint: nil), html_options.merge({
        aria: { describedby: help_text_id(attribute, options) }
      }))
  end

  sig do
    params(
      attribute: T.any(String, Symbol),
      options: T::Hash[Symbol, T.untyped]
    ).returns(T.nilable(ActiveSupport::SafeBuffer))
  end
  def error_for(attribute, options = {})
    if error?(attribute)
      content_tag(:span, super, id: field_id(attribute, :error))
    end
  end

  sig do
    params(
      attribute: T.any(String, Symbol),
      options: T::Hash[T.any(String, Symbol), T.untyped],
      html_options: T.nilable(T::Hash[T.any(String, Symbol), T.untyped]),
      "&": T.proc.params(class_options: T::Hash[T.any(String, Symbol), T.untyped]).returns(T.untyped)
    ).returns(ActiveSupport::SafeBuffer)
  end
  def field(attribute, options, html_options = nil, &)
    if html_options
      super(attribute, options, aria_error_options(attribute).merge(html_options), &)
    else
      super(attribute, aria_error_options(attribute).merge(options), &)
    end
  end

  private

    sig do
      params(
        attribute: T.any(String, Symbol),
        text: T.untyped,
        options: T.nilable(T::Hash[Symbol, T.untyped])
      ).returns(ActiveSupport::SafeBuffer)
    end
    def custom_label(attribute, text, options)
      if text == false
        super
      else
        super(attribute, sanitized_label_text(attribute, text), options)
      end
    end

    sig do
      params(
        attribute: T.any(String, Symbol),
        options: T::Hash[Symbol, T.untyped]
      ).returns(ActiveSupport::SafeBuffer)
    end
    def label_with_hint(attribute, options)
      custom_label(attribute, options[:label], options[:label_options]) +
        help_text(attribute, options)
    end

    sig { params(attribute: T.any(String, Symbol), text: T.untyped).returns(String) }
    def label_text(attribute, text)
      if text.nil? || text == true
        default_label_text(object, attribute)
      else
        text
      end
    end

    sig do
      params(
        attribute: T.any(String, Symbol),
        text: T.untyped
      ).returns(T.nilable(ActiveSupport::SafeBuffer))
    end
    def sanitized_label_text(attribute, text)
      sanitize(label_text(attribute, text), attributes: allowed_attributes)
    end

    sig { returns(T::Set[String]) }
    def allowed_attributes
      self.class.sanitized_allowed_attributes + ["target"]
    end

    sig { params(options: T::Hash[Symbol, T.untyped]).returns(T::Hash[Symbol, T.untyped]) }
    def label_options_for(options)
      label_options = options[:label_options] || {}

      if options[:id]
        { for: options[:id] }.merge(label_options)
      else
        label_options
      end
    end

    sig do
      params(
        attribute: T.any(String, Symbol),
        options: T::Hash[Symbol, T.untyped]
      ).returns(T.nilable(ActiveSupport::SafeBuffer))
    end
    def help_text(attribute, options)
      if options[:hint].present?
        tag.span options[:hint], class: "help-text", id: help_text_id(attribute, options)
      end
    end

    sig do
      params(
        attribute: T.any(String, Symbol),
        options: T::Hash[Symbol, T.untyped]
      ).returns(T.nilable(String))
    end
    def help_text_id(attribute, options)
      if options[:hint].present?
        field_id(attribute, :help_text)
      end
    end

    sig { params(attribute: T.any(String, Symbol)).returns(T::Hash[String, T.untyped]) }
    def aria_error_options(attribute)
      if error?(attribute)
        { "aria-invalid" => true, "aria-errormessage" => field_id(attribute, :error) }
      else
        {}
      end
    end
end
