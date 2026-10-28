# typed: strict
module OmniauthTenantSetup
  class << self
    extend T::Sig

    sig { params(env: T::Hash[String, T.untyped]).void }
    def twitter(env)
      oauth(env, secrets[:twitter_key], secrets[:twitter_secret])
    end

    sig { params(env: T::Hash[String, T.untyped]).void }
    def facebook(env)
      oauth2(env, secrets[:facebook_key], secrets[:facebook_secret])
    end

    sig { params(env: T::Hash[String, T.untyped]).void }
    def google_oauth2(env)
      oauth2(env, secrets[:google_oauth2_key], secrets[:google_oauth2_secret])
    end

    sig { params(env: T::Hash[String, T.untyped]).void }
    def wordpress_oauth2(env)
      oauth2(env, secrets[:wordpress_oauth2_key], secrets[:wordpress_oauth2_secret])
    end

    sig { params(env: T::Hash[String, T.untyped]).void }
    def saml(env)
      env["omniauth.strategy"].options.merge!(saml_settings)
    end

    sig { params(env: T::Hash[String, T.untyped]).void }
    def oidc(env)
      oidc_auth(env, secrets[:oidc_client_id], secrets[:oidc_client_secret], secrets[:oidc_issuer])
    end

    private

      sig do
        params(
          env: T::Hash[String, T.untyped],
          key: T.nilable(T.any(String, Integer)),
          secret: T.nilable(String)
        ).void
      end
      def oauth(env, key, secret)
        unless Tenant.default?
          env["omniauth.strategy"].options[:consumer_key] = key
          env["omniauth.strategy"].options[:consumer_secret] = secret
        end
      end

      sig do
        params(
          env: T::Hash[String, T.untyped],
          key: T.nilable(T.any(String, Integer)),
          secret: T.nilable(String)
        ).void
      end
      def oauth2(env, key, secret)
        unless Tenant.default?
          env["omniauth.strategy"].options[:client_id] = key
          env["omniauth.strategy"].options[:client_secret] = secret
        end
      end

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def saml_settings
        SamlAuthSettings.new(secrets).settings
      end

      sig do
        params(
          env: T::Hash[String, T.untyped],
          client_id: T.nilable(T.any(String, Integer)),
          client_secret: T.nilable(String),
          issuer: T.nilable(String)
        ).void
      end
      def oidc_auth(env, client_id, client_secret, issuer)
        strategy = env["omniauth.strategy"]

        strategy.options[:issuer] = issuer if issuer.present?
        strategy.options[:client_options] ||= {}
        strategy.options[:client_options][:identifier] = client_id if client_id.present?
        strategy.options[:client_options][:secret] = client_secret if client_secret.present?
        strategy.options[:client_options][:redirect_uri] = oidc_redirect_uri if oidc_redirect_uri.present?
      end

      sig { returns(String) }
      def oidc_redirect_uri
        Rails.application.routes.url_helpers.user_oidc_omniauth_callback_url(Tenant.current_url_options)
      end

      sig { returns(ActiveSupport::OrderedOptions) }
      def secrets
        Tenant.current_secrets
      end
  end
end
