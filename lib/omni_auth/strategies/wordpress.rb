# typed: strict
# This code is based on this gem https://github.com/jwickard/omniauth-wordpress-oauth2-plugin

require "omniauth-oauth2"

module OmniAuth
  module Strategies
    class Wordpress < OmniAuth::Strategies::OAuth2
      extend T::Sig

      option :name, :wordpress_oauth2

      option :client_options, {}

      uid do
        T.bind(self, Wordpress)
        raw_info["ID"]
      end

      info do
        T.bind(self, Wordpress)
        {
          name: raw_info["display_name"],
          email: raw_info["user_email"],
          nickname: raw_info["user_nicename"],
          urls: { "Website" => raw_info["user_url"] }
        }
      end

      extra do
        T.bind(self, Wordpress)
        { raw_info: raw_info }
      end

      sig { returns(String) }
      def callback_url
        full_host + script_name + callback_path
      end

      sig { returns(T::Hash[String, T.untyped]) }
      def raw_info
        @raw_info ||= T.let(obtain_raw_info, T.nilable(T::Hash[String, T.untyped]))
      end

      sig { returns(T::Hash[String, T.untyped]) }
      def obtain_raw_info
        access_token.get("/oauth/me", params: { "Authorization" => "Bearer #{access_token.token}" }).parsed
      end
    end
  end
end
