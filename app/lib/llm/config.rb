# typed: strict
module Llm
  class Config
    class << self
      extend T::Sig

      # RubyLLM::Context
      sig { returns(T.untyped) }
      def context
        RubyLLM.context do |config|
          ENV["GOOGLE_APPLICATION_CREDENTIALS"] ||= Rails.application.secrets[:google_application_credentials]

          llm_secrets.compact_blank.each do |key, value|
            config.send("#{key}=", value)
          end
        end
      end

      sig { returns(T::Hash[Symbol, { enabled: T::Boolean }]) }
      def providers
        RubyLLM::Providers.constants.to_h do |provider|
          [provider, { enabled: RubyLLM::Providers.const_get(provider).configured?(context.config) }]
        end
      end

      sig { returns(T::Hash[String, T.untyped]) }
      def prompts
        YAML.load_file("config/llm_prompts.yml", aliases: true)
      end

      # RubyLLM::Chat
      sig { params(provider: T.nilable(Symbol), model: T.nilable(String)).returns(T.untyped) }
      def chat(provider: llm_provider, model: llm_model)
        context.chat(provider: provider, model: model)
      end

      sig { returns(T::Boolean) }
      def configured?
        llm_provider.present? && llm_model.present?
      end

      private

        sig { returns(T.nilable(Symbol)) }
        def llm_provider
          Setting["llm.provider"]&.downcase&.to_sym
        end

        sig { returns(T.nilable(String)) }
        def llm_model
          Setting["llm.model"]
        end

        sig { returns(T::Hash[T.untyped, T.untyped]) }
        def llm_secrets
          Tenant.current_secrets.llm || {}
        end
    end
  end
end
