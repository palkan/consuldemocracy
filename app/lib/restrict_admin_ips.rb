# typed: strict
class RestrictAdminIps
  extend T::Sig

  sig { returns(String) }
  attr_reader :ip

  sig { params(ip: String).void }
  def initialize(ip)
    @ip = ip
  end

  sig { returns(T::Boolean) }
  def allowed?
    unrestricted_access? || allowed_ip?
  end

  private

    sig { returns(T::Boolean) }
    def unrestricted_access?
      allowed_ips.blank?
    end

    sig { returns(T::Array[String]) }
    def allowed_ips
      Array(Tenant.current_secrets.dig(:security, :allowed_admin_ips))
    end

    sig { returns(T::Boolean) }
    def allowed_ip?
      normalized_allowed_ips.any? { |allowed_ip| allowed_ip.include?(ip) }
    rescue IPAddr::Error
      false
    end

    sig { returns(T::Array[IPAddr]) }
    def normalized_allowed_ips
      allowed_ips.map do |allowed_ip|
        IPAddr.new(allowed_ip)
      rescue IPAddr::Error
        Rails.logger.warn "Your allowed_admin_ips configuration includes the " \
                          "address \"#{allowed_ip}\", which is not valid"
        nil
      end.compact
    end
end
