# typed: strict
class Admin::Settings::DropdownFormComponent < ApplicationComponent
  sig { override(allow_incompatible: true).returns(Setting) }
  attr_reader :setting

  sig { returns(T.any(String, T::Array[T.untyped])) }
  attr_reader :options

  sig { returns(T.nilable(String)) }
  attr_reader :tab

  sig { returns(T::Boolean) }
  attr_reader :disabled

  sig do
    params(
      setting: Setting,
      options: T.any(String, T::Array[T.untyped]),
      tab: T.nilable(String),
      disabled: T::Boolean
    ).void
  end
  def initialize(setting, options:, tab: nil, disabled: false)
    @setting = setting
    @options = options
    @tab = tab
    @disabled = disabled
  end
end
