# typed: strict
module IpDeniedHandler
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ApplicationController }

  included do
    before_action :restrict_ip, unless: :allowed_ip?
  end

private

  sig { void }
  def restrict_ip
    redirect_to root_path, alert: t("ip_denied_handler.unauthorized")
  end

  sig { returns(T::Boolean) }
  def allowed_ip?
    RestrictAdminIps.new(request.remote_ip).allowed?
  end
end
