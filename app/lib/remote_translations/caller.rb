# typed: strict
class RemoteTranslations::Caller
  extend T::Sig

  sig { returns(RemoteTranslation) }
  attr_reader :remote_translation

  sig { returns(T::Array[String]) }
  def self.available_locales
    translation_provider.const_get(:AvailableLocales).locales
  end

  sig { returns(T::Boolean) }
  def self.configured?
    llm? || microsoft?
  end

  sig { returns(T::Boolean) }
  def self.llm?
    ::Llm::Config.configured? && Setting["llm.use_llm_for_translations"].present?
  end

  sig { returns(T::Boolean) }
  def self.microsoft?
    Setting["feature.remote_translations"].present? && Tenant.current_secrets.microsoft_api_key.present?
  end

  sig { returns(T.any(T.class_of(RemoteTranslations::Llm), T.class_of(RemoteTranslations::Microsoft))) }
  def self.translation_provider
    return RemoteTranslations::Llm if llm?

    RemoteTranslations::Microsoft
  end

  sig { params(remote_translation: RemoteTranslation).void }
  def initialize(remote_translation)
    @remote_translation = remote_translation
    @resource = T.let(nil, T.untyped)
    @translations = T.let(nil, T.nilable(T::Array[T.nilable(String)]))
  end

  sig { void }
  def call
    update_resource
    destroy_remote_translation
  end

  private

    sig { returns(T::Boolean) }
    def update_resource
      Globalize.with_locale(locale) do
        resource.translated_attribute_names.each_with_index do |field, index|
          resource.send(:"#{field}=", translations[index])
        end
      end
      resource.save
    end

    sig { void }
    def destroy_remote_translation
      if resource.valid?
        remote_translation.destroy
        resource.save!
      else
        remote_translation.update(error_message: resource.errors.messages)
      end
    end

    # Any translatable model (Debate, Proposal, Comment...)
    sig { returns(T.untyped) }
    def resource
      @resource ||= remote_translation.remote_translatable
    end

    sig { returns(T::Array[T.nilable(String)]) }
    def translations
      @translations ||= self.class.translation_provider.const_get(:Client).new.call(fields_values, locale)
    end

    sig { returns(T::Array[T.nilable(String)]) }
    def fields_values
      resource.translated_attribute_names.map do |field|
        WYSIWYGSanitizer.new.sanitize(resource.send(field))
      end
    end

    sig { returns(T.nilable(String)) }
    def locale
      remote_translation.locale
    end
end
