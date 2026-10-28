# typed: strict
class Verification::Email
  extend T::Sig
  include ActiveModel::Model

  sig { returns(T.nilable(VerifiedUser)) }
  attr_accessor :verified_user

  sig { returns(T.nilable(String)) }
  attr_accessor :recipient, :plain_token, :encrypted_token

  validates :verified_user, presence: true
  validates :recipient, presence: true

  sig { params(verified_user: T.nilable(VerifiedUser)).void }
  def initialize(verified_user)
    @verified_user = verified_user
    @recipient = T.let(@verified_user&.email, T.nilable(String))
    @plain_token = T.let(nil, T.nilable(String))
    @encrypted_token = T.let(nil, T.nilable(String))
  end

  sig { returns(T::Boolean) }
  def save
    return false unless valid?

    generate_token
    T.must(user).update!(email_verification_token: @plain_token)
  end

  sig { returns(T.nilable(User)) }
  def user
    User.find_by(document_number: T.must(verified_user).document_number)
  end

  sig { returns(T::Array[String]) }
  def generate_token
    @plain_token, @encrypted_token = Devise.token_generator.generate(User, :email_verification_token)
  end

  sig { params(user: User, token: T.nilable(String)).returns(T::Boolean) }
  def self.valid_token?(user, token)
    Devise.token_generator.digest(User, :email_verification_token, user.email_verification_token) == token
  end
end
