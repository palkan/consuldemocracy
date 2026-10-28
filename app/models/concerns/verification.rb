# typed: strict
module Verification
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { User }

  included do
    scope :residence_verified, -> { where.not(residence_verified_at: nil) }
    scope :residence_unverified, -> { where(residence_verified_at: nil) }
    scope :residence_and_phone_verified, -> { residence_verified.where.not(confirmed_phone: nil) }
    scope :residence_or_phone_unverified, -> { residence_unverified.or(where(confirmed_phone: nil)) }
    scope :phone_not_fully_confirmed, -> { where(unconfirmed_phone: nil).or(where(confirmed_phone: nil)) }

    scope :level_three_verified, -> { where.not(verified_at: nil) }
    scope :level_two_verified, -> do
      where.not(level_two_verified_at: nil).or(residence_and_phone_verified.where(verified_at: nil))
    end
    scope :level_two_or_three_verified, -> { level_two_verified.or(level_three_verified) }
    scope :unverified, -> do
      residence_or_phone_unverified.where(verified_at: nil, level_two_verified_at: nil)
    end
    scope :incomplete_verification, -> do
      residence_unverified.where(failed_census_calls_count: 1..)
                          .or(residence_verified.phone_not_fully_confirmed)
    end
  end

  sig { returns(T::Boolean) }
  def skip_verification?
    Setting["feature.user.skip_verification"].present?
  end

  sig { returns(T::Boolean) }
  def verification_email_sent?
    return true if skip_verification?

    email_verification_token.present?
  end

  sig { returns(T::Boolean) }
  def verification_sms_sent?
    return true if skip_verification?

    unconfirmed_phone.present? && sms_confirmation_code.present?
  end

  sig { returns(T::Boolean) }
  def verification_letter_sent?
    return true if skip_verification?

    letter_requested_at.present? && letter_verification_code.present?
  end

  sig { returns(T::Boolean) }
  def residence_verified?
    return true if skip_verification?

    residence_verified_at.present?
  end

  sig { returns(T::Boolean) }
  def sms_verified?
    return true if skip_verification?

    confirmed_phone.present?
  end

  sig { returns(T::Boolean) }
  def level_two_verified?
    return true if skip_verification?

    level_two_verified_at.present? || (residence_verified? && sms_verified?)
  end

  sig { returns(T::Boolean) }
  def level_three_verified?
    return true if skip_verification?

    verified_at.present?
  end

  sig { returns(T::Boolean) }
  def level_two_or_three_verified?
    level_two_verified? || level_three_verified?
  end

  sig { returns(T::Boolean) }
  def unverified?
    !level_two_or_three_verified?
  end

  sig { returns(T::Boolean) }
  def failed_residence_verification?
    !residence_verified? && !failed_census_calls.empty?
  end

  sig { returns(T::Boolean) }
  def no_phone_available?
    !verification_sms_sent?
  end

  sig { returns(Symbol) }
  def user_type
    if level_three_verified?
      :level_3_user
    elsif level_two_verified?
      :level_2_user
    else
      :level_1_user
    end
  end

  sig { returns(T::Boolean) }
  def sms_code_not_confirmed?
    !sms_verified?
  end
end
