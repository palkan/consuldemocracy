# typed: strict
class Admin::ToggleSwitchComponent < ApplicationComponent
  sig { returns(Symbol) }
  attr_reader :action

  sig { returns(T.untyped) }
  attr_reader :record

  sig { returns(T::Boolean) }
  attr_reader :pressed

  sig { returns(T::Hash[Symbol, T.untyped]) }
  attr_reader :options

  alias_method :pressed?, :pressed

  sig { params(action: Symbol, record: T.untyped, pressed: T::Boolean, options: T.untyped).void }
  def initialize(action, record, pressed:, **options)
    @action = action
    @record = record
    @pressed = pressed
    @options = options
  end

  private

    sig { returns(String) }
    def text
      if pressed?
        t("shared.yes")
      else
        t("shared.no")
      end
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def default_options
      {
        text: text,
        method: :patch,
        remote: true,
        "aria-pressed": pressed?,
        form_class: "toggle-switch #{options[:form_class]}".strip
      }
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def html_options
      default_options.merge(options.except(:form_class))
    end
end
