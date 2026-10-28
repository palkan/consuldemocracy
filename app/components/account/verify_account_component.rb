# typed: strict
class Account::VerifyAccountComponent < ApplicationComponent
  sig { returns(User) }
  attr_reader :account

  sig { params(account: User).void }
  def initialize(account)
    @account = account
  end

  sig { returns(T::Boolean) }
  def render?
    Setting["feature.user.skip_verification"].blank? && !account.organization?
  end
end
