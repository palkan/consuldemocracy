# typed: strict
class Verification::Letter
  extend T::Sig
  include ActiveModel::Model

  sig { returns(T.nilable(User)) }
  attr_accessor :user

  sig { returns(T.nilable(String)) }
  attr_accessor :verification_code, :email, :password

  sig { returns(T.untyped) }
  attr_accessor :verify

  validate :validate_existing_user

  validates :email, presence: true, if: :verify?
  validates :password, presence: true, if: :verify?
  validates :verification_code, presence: true, if: :verify?

  validate :validate_correct_code, if: :verify?

  sig { returns(T.nilable(T::Boolean)) }
  def save
    valid? && letter_requested!
  end

  sig { returns(T.nilable(T::Boolean)) }
  def save!
    validate! && save
  end

  sig { returns(T::Boolean) }
  def letter_requested!
    T.must(user).update(letter_requested_at: Time.current,
                        letter_verification_code: generate_verification_code)
  end

  sig { void }
  def validate_existing_user
    unless user
      errors.add(:email, I18n.t("devise.failure.invalid", authentication_keys: "email"))
    end
  end

  sig { void }
  def validate_correct_code
    return if errors.include?(:verification_code)

    if user&.letter_verification_code.to_i != verification_code.to_i
      errors.add(:verification_code, I18n.t("verification.letter.errors.incorrect_code"))
    end
  end

  sig { returns(T::Boolean) }
  def verify?
    verify.present?
  end

  # The users table has no `letter_verification_tries` column, so Sorbet can't type this method
  sig { returns(T.untyped) }
  def increase_letter_verification_tries
    user = T.unsafe(self.user)
    user.update(letter_verification_tries: user.letter_verification_tries += 1)
  end

  private

    # six-digit numbers, zero not the first digit
    sig { returns(String) }
    def generate_verification_code
      rand(100000..999999).to_s
    end
end
