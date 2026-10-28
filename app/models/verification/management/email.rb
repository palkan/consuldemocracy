# typed: strict
class Verification::Management::Email
  extend T::Sig
  include ActiveModel::Model

  sig { returns(T.nilable(String)) }
  attr_accessor :document_type, :document_number, :email

  validates :document_type, :document_number, :email, presence: true
  validates :email, format: { with: Devise.email_regexp }, allow_blank: true
  validate :validate_user
  validate :validate_document_number

  delegate :username, to: :user, allow_nil: true

  sig { returns(T.nilable(User)) }
  def user
    return @user if defined?(@user)

    @user = T.let(User.find_by(email: email), T.nilable(User))
  end

  sig { returns(T::Boolean) }
  def user?
    user.present?
  end

  sig { returns(T::Boolean) }
  def save
    return false unless valid?

    plain_token, encrypted_token = Devise.token_generator.generate(User, :email_verification_token)

    user = T.must(self.user)
    user.update!(document_type: document_type,
                 document_number: document_number,
                 residence_verified_at: Time.current,
                 level_two_verified_at: Time.current,
                 email_verification_token: plain_token)

    Mailer.email_verification(user, email, encrypted_token, document_type, document_number).deliver_later
    true
  end

  sig { returns(T.nilable(T::Boolean)) }
  def save!
    validate! && save
  end

  private

    sig { void }
    def validate_user
      return if errors.any?

      if !user?
        errors.add(:email, I18n.t("errors.messages.user_not_found"))
      elsif T.must(user).level_three_verified?
        errors.add(:email, I18n.t("management.email_verifications.already_verified"))
      end
    end

    sig { void }
    def validate_document_number
      return if errors.any?

      if document_number_mismatch?
        user = T.must(self.user)
        helpers = T.cast(ApplicationController.helpers, UsersHelper)
        errors.add(
          :email,
          I18n.t("management.email_verifications.document_mismatch",
                 document_type: helpers.humanize_document_type(user.document_type),
                 document_number: user.document_number)
        )
      end
    end

    sig { returns(T::Boolean) }
    def document_number_mismatch?
      user = self.user
      !user.nil? && user.document_number.present? &&
        (user.document_number != document_number || user.document_type != document_type)
    end
end
