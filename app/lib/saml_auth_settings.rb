# typed: strict
class SamlAuthSettings
  extend T::Sig

  sig { returns(ActiveSupport::OrderedOptions) }
  attr_reader :secrets

  sig { params(secrets: ActiveSupport::OrderedOptions).void }
  def initialize(secrets)
    @secrets = secrets
  end

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def settings
    self.class.remote_settings(idp_metadata_url).dup.tap do |settings|
      settings[:sp_entity_id] = sp_entity_id if sp_entity_id.present?
      settings[:idp_sso_service_url] = idp_sso_service_url if idp_sso_service_url.present?
      settings[:allowed_clock_drift] = 1.minute

      settings.merge!(additional_settings)

      if settings[:certificate].present? && settings[:private_key].present?
        settings[:security] = security_settings.merge(settings[:security] || {})
      end
    end
  end

  sig { params(idp_metadata_url: T.nilable(String)).returns(T::Hash[Symbol, T.untyped]) }
  def self.remote_settings(idp_metadata_url)
    return {} if idp_metadata_url.blank?

    @remote_settings ||= T.let({}, T.nilable(T::Hash[String, T::Hash[Symbol, T.untyped]]))
    @remote_settings[idp_metadata_url] ||= parsed_metadata(idp_metadata_url)
  end

  sig { params(idp_metadata_url: String).returns(T::Hash[Symbol, T.untyped]) }
  def self.parsed_metadata(idp_metadata_url)
    OneLogin::RubySaml::IdpMetadataParser.new.parse_remote_to_hash(idp_metadata_url)
  end

  private

    sig { returns(T.nilable(String)) }
    def idp_metadata_url
      secrets[:saml_idp_metadata_url]
    end

    sig { returns(T.nilable(String)) }
    def sp_entity_id
      secrets[:saml_sp_entity_id]
    end

    sig { returns(T.nilable(String)) }
    def idp_sso_service_url
      secrets[:saml_idp_sso_service_url]
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def additional_settings
      secrets[:saml_additional_settings].presence || {}
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def security_settings
      {
        authn_requests_signed: true,
        want_assertions_encrypted: true,
        digest_method: XMLSecurity::Document::SHA256,
        signature_method: XMLSecurity::Document::RSA_SHA256
      }
    end
end
