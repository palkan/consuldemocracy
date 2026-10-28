# typed: strict
class Devise::OmniauthFormComponent < ApplicationComponent
  sig { returns(String) }
  attr_reader :action

  sig { params(action: String).void }
  def initialize(action)
    @action = action
  end

  sig { returns(T::Boolean) }
  def render?
    oauth_logins.any?
  end

  private

    sig { returns(T::Array[Symbol]) }
    def oauth_logins
      [
        (:twitter if feature?(:twitter_login)),
        (:facebook if feature?(:facebook_login)),
        (:google_oauth2 if feature?(:google_login)),
        (:wordpress_oauth2 if feature?(:wordpress_login)),
        (:saml if feature?(:saml_login)),
        (:oidc if feature?(:oidc_login))
      ].compact
    end
end
