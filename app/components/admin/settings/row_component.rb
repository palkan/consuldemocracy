# typed: strict
class Admin::Settings::RowComponent < ApplicationComponent
  sig { returns(String) }
  attr_reader :key

  sig { returns(T.nilable(String)) }
  attr_reader :tab

  sig { returns(Symbol) }
  attr_reader :type

  sig { returns(T.nilable(T.any(String, T::Array[T.untyped]))) }
  attr_reader :options

  sig { returns(T::Boolean) }
  attr_reader :disabled

  delegate :dom_id, to: :helpers

  sig do
    params(
      key: String,
      type: Symbol,
      tab: T.nilable(String),
      options: T.nilable(T.any(String, T::Array[T.untyped])),
      disabled: T::Boolean
    ).void
  end
  def initialize(key, type: :text, tab: nil, options: nil, disabled: false)
    @key = key
    @type = type
    @tab = tab
    @options = options
    @disabled = disabled
    @setting = T.let(nil, T.nilable(Setting))
  end

  sig { override(allow_incompatible: true).returns(Setting) }
  def setting
    @setting ||= Setting.find_by!(key: key)
  end

  sig { returns(T::Boolean) }
  def content_type_setting?
    type == :content_type
  end

  sig { returns(T::Boolean) }
  def featured_setting?
    type == :feature
  end

  sig { returns(T::Boolean) }
  def dropdown_setting?
    type == :dropdown
  end
end
