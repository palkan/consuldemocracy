# typed: strict
# Included in views, components (ApplicationComponent) and models (SDG::ProcessEnabled)
module SettingsHelper
  extend T::Sig

  sig { params(name: T.any(String, Symbol)).returns(T.nilable(String)) }
  def feature?(name)
    setting["feature.#{name}"].presence || setting["process.#{name}"].presence || setting[name].presence
  end

  # The keys are strings, but `setting` is also called with symbols
  sig { overridable.returns(T::Hash[T.untyped, T.nilable(String)]) }
  def setting
    @all_settings ||= T.let(
      Setting.all.to_h { |s| [s.key, s.value.presence] },
      T.nilable(T::Hash[T.untyped, T.nilable(String)])
    )
  end
end
