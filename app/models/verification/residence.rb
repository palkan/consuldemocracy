# typed: strict
class Verification::Residence
  extend T::Sig
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks

  attribute :date_of_birth, :date
  sig { returns(T.nilable(User)) }
  attr_accessor :user

  sig { returns(T.nilable(String)) }
  attr_accessor :document_number, :document_type, :postal_code

  sig { returns(T.untyped) }
  attr_accessor :terms_of_service

  validates :document_number, presence: true
  validates :document_type, presence: true
  validates :date_of_birth, presence: true
  validates :postal_code, presence: true
  validates :terms_of_service, acceptance: { allow_nil: false }

  validate :allowed_age
  validate :document_number_uniqueness

  validate :local_postal_code
  validate :local_residence

  sig { params(attrs: T.untyped).void }
  def initialize(attrs = {})
    super
    clean_document_number
  end

  sig { returns(T::Boolean) }
  def save
    return false unless valid?

    user = T.must(self.user)
    user.take_votes_if_erased_document(document_number, document_type)

    user.update(document_number: document_number,
                document_type: document_type,
                geozone: geozone,
                date_of_birth: T.must(date_of_birth).in_time_zone.to_datetime,
                gender: gender,
                residence_verified_at: Time.current)
  end

  sig { returns(T.nilable(T::Boolean)) }
  def save!
    validate! && save
  end

  sig { void }
  def allowed_age
    return if errors[:date_of_birth].any? || T.must(Age.in_years(date_of_birth)) >= User.minimum_required_age

    errors.add(:date_of_birth, I18n.t("verification.residence.new.error_not_allowed_age"))
  end

  sig { void }
  def document_number_uniqueness
    if User.active.where(document_number: document_number).any?
      errors.add(:document_number, I18n.t("errors.messages.taken"))
    end
  end

  sig { returns(FailedCensusCall) }
  def store_failed_attempt
    FailedCensusCall.create(
      user: user,
      document_number: document_number,
      document_type: document_type,
      date_of_birth: date_of_birth,
      postal_code: postal_code
    )
  end

  sig { returns(T.nilable(Geozone)) }
  def geozone
    Geozone.find_by(census_code: district_code)
  end

  sig { returns(T.untyped) }
  def district_code
    census_data.district_code
  end

  sig { returns(T.untyped) }
  def gender
    census_data.gender
  end

  sig { void }
  def local_postal_code
    errors.add(:postal_code,
               I18n.t("verification.residence.new.error_not_allowed_postal_code")) unless valid_postal_code?
  end

  sig { void }
  def local_residence
    return if errors.any?

    unless residency_valid?
      errors.add(:local_residence, false)
      store_failed_attempt
      Lock.increase_tries(user)
    end
  end

  private

    sig { returns(T.untyped) }
    def census_data
      @census_data ||= T.let(
        CensusCaller.new.call(document_type, document_number, date_of_birth, postal_code),
        T.untyped
      )
    end

    sig { returns(T::Boolean) }
    def residency_valid?
      census_data.valid? &&
        census_data.postal_code == postal_code &&
        census_data.date_of_birth == date_of_birth
    end

    sig { void }
    def clean_document_number
      document_number = self.document_number
      self.document_number = document_number.gsub(/[^a-z0-9]+/i, "").upcase if document_number.present?
    end

    sig { returns(T::Boolean) }
    def valid_postal_code?
      return true if Setting["postal_codes"].blank?

      T.must(Setting["postal_codes"]).split(",").any? do |code_or_range|
        if code_or_range.include?(":")
          T.unsafe(Range).new(*code_or_range.split(":").map(&:strip)).include?(postal_code&.strip)
        else
          /\A#{code_or_range.strip}\Z/.match?(postal_code&.strip)
        end
      end
    end
end
