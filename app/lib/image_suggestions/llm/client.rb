# typed: strict
module ImageSuggestions
  module Llm
    class Client
      extend T::Sig

      NUMBER_OF_IMAGES = 8

      sig { params(title: T.nilable(String), description: T.nilable(String)).returns(Response) }
      def self.call(title:, description:)
        new(title: title, description: description).call
      end

      sig { params(title: T.nilable(String), description: T.nilable(String)).void }
      def initialize(title:, description:)
        @title = title
        @description = description
        @response = T.let(nil, T.nilable(Response))
        @chat = T.let(nil, T.untyped)
        @prompt = T.let(nil, T.nilable(String))
      end

      sig { returns(Response) }
      def call
        validate_llm_settings!
        return response if response.errors.any?

        search_query = generate_search_query
        return response if response.errors.any?

        results = ImageSuggestions::Pexels.search(T.must(search_query), per_page: NUMBER_OF_IMAGES)
        response.results = results
      rescue ::Pexels::APIError, RubyLLM::Error => e
        response.errors << e.message
      ensure
        return response
      end

      sig { returns(Response) }
      def response
        @response ||= Response.new
      end

      class Response
        extend T::Sig

        # The photos returned by Pexels
        sig { returns(T.untyped) }
        attr_accessor :results

        sig { returns(T::Array[String]) }
        attr_reader :errors

        sig { void }
        def initialize
          @results = T.let([], T.untyped)
          @errors = T.let([], T::Array[String])
        end
      end

      private

        # RubyLLM::Chat
        sig { returns(T.untyped) }
        def chat
          @chat ||= ::Llm::Config.chat
        end

        sig { returns(T.nilable(String)) }
        def generate_search_query
          if @title.blank? && @description.blank?
            response.errors << I18n.t("images.errors.messages.title_and_description_required")
            return
          end

          text_prompt = prompt % { title: @title, description: @description }
          chat.ask(text_prompt).content.strip
        end

        sig { returns(String) }
        def prompt
          @prompt ||= ::Llm::Config.prompts["image_suggestion_prompt"]
        end

        sig { void }
        def validate_llm_settings!
          unless ::Llm::Config.configured? && Setting["llm.use_ai_image_suggestions"].present?
            response.errors << I18n.t("images.errors.messages.llm_not_configured")
          end
        end
    end
  end
end
