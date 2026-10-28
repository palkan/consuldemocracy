# typed: strict
module RemoteTranslations
  module Llm
    class Client
      extend T::Sig

      sig do
        params(
          fields_values: T::Array[T.nilable(String)],
          locale: T.nilable(T.any(String, Symbol))
        ).returns(T::Array[T.nilable(String)])
      end
      def call(fields_values, locale)
        fields_values.map do |text|
          request_translation(text, locale)
        end
      end

      private

        # RubyLLM::Chat
        sig { returns(T.untyped) }
        def chat
          @chat ||= T.let(::Llm::Config.chat, T.untyped)
        end

        sig { returns(String) }
        def prompt
          @prompt ||= T.let(::Llm::Config.prompts["remote_translation_prompt"], T.nilable(String))
        end

        sig do
          params(
            text: T.nilable(String),
            locale: T.nilable(T.any(String, Symbol))
          ).returns(T.nilable(String))
        end
        def request_translation(text, locale)
          text_prompt = prompt % { input_text: text, output_locale: locale }
          chat.ask(text_prompt).content
        end
    end
  end
end
