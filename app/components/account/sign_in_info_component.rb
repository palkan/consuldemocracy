# typed: strict
class Account::SignInInfoComponent < ApplicationComponent
  sig { returns(User) }
  attr_reader :account

  sig { params(account: User).void }
  def initialize(account)
    @account = account
  end

  sig { returns(T.untyped) }
  def render?
    Tenant.current_secrets.dig(:security, :last_sign_in)
  end
end
