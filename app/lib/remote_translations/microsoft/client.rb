# typed: strict
class RemoteTranslations::Microsoft::Client
  extend T::Sig
  include RemoteTranslations::Microsoft::SentencesParser

  CHARACTERS_LIMIT_PER_REQUEST = 5000
  PREVENTING_TRANSLATION_KEY = T.let("notranslate".freeze, String)

  sig do
    params(
      fields_values: T::Array[T.nilable(String)],
      locale: T.nilable(T.any(String, Symbol))
    ).returns(T::Array[T.nilable(String)])
  end
  def call(fields_values, locale)
    texts = prepare_texts(fields_values)
    valid_locale = RemoteTranslations::Microsoft::AvailableLocales.app_locale_to_remote_locale(locale)
    request_translation(texts, valid_locale)
  end

  sig { params(text: String).returns(T::Array[String]) }
  def fragments_for(text)
    return [text] if text.size <= CHARACTERS_LIMIT_PER_REQUEST

    split_position = detect_split_position(text)
    start_text = T.must(text[0..split_position])
    end_text = T.must(text[split_position + 1..text.size])

    fragments_for(start_text) + [end_text]
  end

  private

    sig { returns(BingTranslator) }
    def client
      @client ||= T.let(
        BingTranslator.new(Tenant.current_secrets.microsoft_api_key),
        T.nilable(BingTranslator)
      )
    end

    sig do
      params(
        texts: T::Array[String],
        locale: T.nilable(T.any(String, Symbol))
      ).returns(T::Array[T.nilable(String)])
    end
    def request_translation(texts, locale)
      response = []
      split_response = false

      if characters_count(texts) <= CHARACTERS_LIMIT_PER_REQUEST
        response = client.translate_array(texts, to: locale)
      else
        texts.each do |text|
          response << translate_text(text, locale)
        end
        split_response = true
      end

      parse_response(response, split_response)
    end

    sig { params(text: String, locale: T.nilable(T.any(String, Symbol))).returns(T::Array[String]) }
    def translate_text(text, locale)
      fragments_for(text).map do |fragment|
        client.translate_array([fragment], to: locale)
      end.flatten
    end

    sig do
      params(
        response: T::Array[T.untyped],
        split_response: T::Boolean
      ).returns(T::Array[T.nilable(String)])
    end
    def parse_response(response, split_response)
      response.map do |translation|
        if split_response
          build_translation(translation)
        else
          get_field_value(translation)
        end
      end
    end

    sig { params(translations: T::Array[String]).returns(String) }
    def build_translation(translations)
      translations.map { |translation| get_field_value(translation) }.join
    end

    sig { params(translation: String).returns(T.nilable(String)) }
    def get_field_value(translation)
      notranslate?(translation) ? nil : translation
    end

    sig { params(texts: T::Array[T.nilable(String)]).returns(T::Array[String]) }
    def prepare_texts(texts)
      texts.map { |text| text || PREVENTING_TRANSLATION_KEY }
      #https://docs.microsoft.com/es-es/azure/cognitive-services/translator/prevent-translation
    end

    sig { params(text: String).returns(T::Boolean) }
    def notranslate?(text)
      text.downcase == PREVENTING_TRANSLATION_KEY
    end
end
