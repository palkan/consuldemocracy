# typed: strict
class Layout::CookiesConsent::SwitchComponent < ApplicationComponent
  sig { returns(T::Boolean) }
  attr_reader :checked, :disabled

  sig { returns(T.any(String, Symbol)) }
  attr_reader :name

  sig { returns(String) }
  attr_reader :label

  sig { returns(T.nilable(String)) }
  attr_reader :description

  sig do
    params(
      name: T.any(String, Symbol),
      label: String,
      description: T.nilable(String),
      checked: T::Boolean,
      disabled: T::Boolean
    ).void
  end
  def initialize(name, label:, description:, checked: false, disabled: false)
    @name = name
    @label = label
    @description = description
    @checked = checked
    @disabled = disabled
  end

  private

    sig { returns(T::Boolean) }
    def checked?
      checked == true
    end

    sig { returns(T::Boolean) }
    def disabled?
      disabled == true
    end
end
