# typed: strict
require "net/https"
require "uri"
require "cgi"
require "json"

class RemoteTranslations::Microsoft::AvailableLocales
  extend T::Sig

  sig { returns(T::Array[String]) }
  def self.locales
    daily_cache("locales") do
      remote_available_locales.map { |locale| remote_locale_to_app_locale(locale) }
    end
  end

  sig { params(locale: T.nilable(T.any(String, Symbol))).returns(T.nilable(T.any(String, Symbol))) }
  def self.app_locale_to_remote_locale(locale)
    app_locale_to_remote_locale_map[locale] || locale
  end

  private

    sig { params(locale: String).returns(String) }
    def self.remote_locale_to_app_locale(locale)
      app_locale_to_remote_locale_map.invert[locale] || locale
    end

    sig { returns(T::Hash[T.untyped, String]) }
    def self.app_locale_to_remote_locale_map
      {
        "pt-BR" => "pt",
        "zh-CN" => "zh-Hans",
        "zh-TW" => "zh-Hant"
      }
    end

    sig { returns(T::Array[String]) }
    def self.remote_available_locales
      host = "https://api.cognitive.microsofttranslator.com"
      path = "/languages?api-version=3.0"

      uri = URI(host + path)

      request = Net::HTTP::Get.new(uri)
      request["Ocp-Apim-Subscription-Key"] = Tenant.current_secrets.microsoft_api_key

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end

      result = response.body.force_encoding("utf-8")

      JSON.parse(result)["translation"].map(&:first)
    end

    sig { params(key: String, "&": T.proc.returns(T::Array[String])).returns(T::Array[String]) }
    def self.daily_cache(key, &)
      Rails.cache.fetch("remote_available_locales/#{Time.current.strftime("%Y-%m-%d")}/#{key}", &)
    end
end
