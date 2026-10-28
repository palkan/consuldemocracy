# typed: strict
class Verification::Sms
  extend T::Sig
  include ActiveModel::Model

  sig { returns(T.nilable(User)) }
  attr_accessor :user

  sig { returns(T.nilable(String)) }
  attr_accessor :phone, :confirmation_code

  validates :phone, presence: true
  validates :phone, format: { with: /\A[\d \+]+\z/ }
  validate :uniqness_phone

  sig { void }
  def uniqness_phone
    errors.add(:phone, :taken) if User.where(confirmed_phone: phone).any?
  end

  sig { returns(T::Boolean) }
  def save
    return false unless valid?

    update_user_phone_information
    send_sms
    Lock.increase_tries(user)
  end

  sig { returns(T::Boolean) }
  def update_user_phone_information
    T.must(user).update(unconfirmed_phone: phone, sms_confirmation_code: generate_confirmation_code)
  end

  sig { returns(T.untyped) }
  def send_sms
    user = T.must(self.user)
    SmsApi.new.sms_deliver(user.unconfirmed_phone, user.sms_confirmation_code)
  end

  sig { returns(T::Boolean) }
  def verified?
    T.must(user).sms_confirmation_code == confirmation_code
  end

  private

    sig { returns(T.nilable(String)) }
    def generate_confirmation_code
      rand.to_s[2..5]
    end
end
