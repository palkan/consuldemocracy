# typed: strict
class InstallationController < ApplicationController
  skip_authorization_check

  sig { void }
  def details
    respond_to do |format|
      format.any { render json: consul_installation_details.to_json, content_type: "application/json" }
    end
  end

  private

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def consul_installation_details
      { release: "2.6.1" }.merge(features: settings_feature_flags)
    end

    sig { returns(T::Hash[String, T.nilable(String)]) }
    def settings_feature_flags
      Setting.where("key LIKE 'process.%'")
             .pluck(:key, :value)
             .to_h
             .transform_keys { |key| key.remove("process.") }
    end
end
