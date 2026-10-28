# typed: strict
class Admin::Settings::LlmConfigurationTabComponent < ApplicationComponent
  sig { returns(String) }
  def tab
    "#tab-llm-configuration"
  end

  sig { returns(T::Hash[Symbol, { enabled: T::Boolean }]) }
  def providers
    Llm::Config.providers
  end

  sig { returns(ActiveSupport::SafeBuffer) }
  def provider_options
    current = Setting["llm.provider"]
    options_values = providers.keys.map { |key| [key.to_s, key.to_s] }
    disabled_values = providers.reject { |_key, value| value[:enabled] }.keys

    options_for_select(options_values, selected: current, disabled: disabled_values)
  end

  sig { returns(T::Hash[T.untyped, T::Hash[Symbol, T.untyped]]) }
  def models
    provider = Setting["llm.provider"]
    return {} if provider.blank?

    RubyLLM.models.by_provider(provider.downcase.to_sym).to_h do |model|
      [model.name, { id: model.id }]
    end
  end

  sig { returns(ActiveSupport::SafeBuffer) }
  def model_options
    current = Setting["llm.model"]
    options_values = models.map { |name, value| [name, value[:id]] }

    options_for_select(options_values, selected: current)
  end

  sig { returns(T::Boolean) }
  def model_disabled?
    Setting["llm.provider"].blank?
  end

  sig { returns(T::Boolean) }
  def feature_disabled?
    !::Llm::Config.configured?
  end

  sig { returns(T::Boolean) }
  def image_suggestions_disabled?
    !::Llm::Config.configured? || Tenant.current_secrets.pexels_access_key.blank?
  end
end
