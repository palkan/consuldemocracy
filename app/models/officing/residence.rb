# typed: strict
class Officing::Residence
  extend T::Sig
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks

  attribute :date_of_birth, :date
  sig { returns(T.nilable(User)) }
  attr_accessor :user

  sig { returns(T.nilable(Poll::Officer)) }
  attr_accessor :officer

  sig { returns(T.nilable(String)) }
  attr_accessor :document_number, :document_type, :postal_code

  sig { returns(T.nilable(T.any(String, Integer))) }
  attr_accessor :year_of_birth

  before_validation :retrieve_census_data

  validates :document_number, presence: true
  validates :document_type, presence: true
  validates :date_of_birth, presence: true, if: -> { Setting.force_presence_date_of_birth? }
  validates :postal_code, presence: true, if: -> { Setting.force_presence_postal_code? }
  validates :year_of_birth, presence: true, unless: -> { Setting.force_presence_date_of_birth? }

  validate :allowed_age
  validate :local_residence

  sig { params(attrs: T.untyped).void }
  def initialize(attrs = {})
    super
    @census_api_response = T.let(@census_api_response, T.untyped)
    clean_document_number
  end

  sig { returns(T.any(T::Boolean, User)) }
  def save
    return false unless valid?

    if user_exists?
      user = self.user = T.must(find_user_by_document)
      user.update!(verified_at: Time.current)
    else
      user_params = {
        document_number: document_number,
        document_type: document_type,
        residence_verified_at: Time.current
      }

      self.user = User.create_from_census_response!(@census_api_response, user_params)
    end
  end

  sig { returns(T.nilable(T.any(T::Boolean, User))) }
  def save!
    validate! && save
  end

  sig { returns(FailedCensusCall) }
  def store_failed_census_call
    FailedCensusCall.create(
      user: user,
      document_number: document_number,
      document_type: document_type,
      date_of_birth: date_of_birth,
      postal_code: postal_code,
      year_of_birth: year_of_birth,
      poll_officer: officer
    )
  end

  sig { returns(T::Boolean) }
  def user_exists?
    find_user_by_document.present?
  end

  sig { returns(T.nilable(User)) }
  def find_user_by_document
    User.find_by(document_number: document_number, document_type: document_type)
  end

  sig { void }
  def local_residence
    return if errors.any?

    unless residency_valid?
      store_failed_census_call
      errors.add(:local_residence, false)
    end
  end

  sig { void }
  def allowed_age
    return if errors[:year_of_birth].any?
    return unless @census_api_response.valid?

    unless allowed_age?
      errors.add(:year_of_birth, I18n.t("verification.residence.new.error_not_allowed_age"))
    end
  end

  sig { returns(T::Boolean) }
  def allowed_age?
    T.must(Age.in_years(response_date_of_birth)) >= User.minimum_required_age
  end

  sig { returns(T.untyped) }
  def response_date_of_birth
    @census_api_response.date_of_birth
  end

  private

    sig { void }
    def retrieve_census_data
      @census_api_response = CensusCaller.new.call(document_type,
                                                   document_number,
                                                   date_of_birth,
                                                   postal_code)
    end

    sig { returns(T.nilable(T::Boolean)) }
    def residency_valid?
      @census_api_response.valid? && valid_year_of_birth?
    end

    sig { returns(T::Boolean) }
    def valid_year_of_birth?
      return true if Setting.force_presence_date_of_birth?

      @census_api_response.date_of_birth.year.to_s == year_of_birth.to_s
    end

    sig { void }
    def clean_document_number
      document_number = self.document_number
      self.document_number = document_number.gsub(/[^a-z0-9]+/i, "").upcase if document_number.present?
    end
end
