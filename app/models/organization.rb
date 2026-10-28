# typed: strict
class Organization < ApplicationRecord
  include Graphqlable

  belongs_to :user, touch: true

  validates :name, presence: true
  validates :name, uniqueness: true
  validate  :validate_name_length
  validates :responsible_name, presence: true
  validate  :validate_responsible_name_length

  delegate :email, :phone_number, to: :user

  scope :pending, -> { where(verified_at: nil, rejected_at: nil) }
  scope :verified, -> do
    where.not(verified_at: nil).where("(rejected_at IS NULL or rejected_at < organizations.verified_at)")
  end
  scope :rejected, -> do
    where.not(rejected_at: nil)
         .where("(organizations.verified_at IS NULL or organizations.verified_at < rejected_at)")
  end

  sig { returns(T::Boolean) }
  def verify
    update(verified_at: Time.current)
  end

  sig { returns(T::Boolean) }
  def reject
    update(rejected_at: Time.current)
  end

  sig { returns(T::Boolean) }
  def verified?
    verified_at = self.verified_at
    rejected_at = self.rejected_at
    !verified_at.nil? && (rejected_at.nil? || rejected_at < verified_at)
  end

  sig { returns(T::Boolean) }
  def rejected?
    verified_at = self.verified_at
    rejected_at = self.rejected_at
    !rejected_at.nil? && (verified_at.nil? || verified_at < rejected_at)
  end

  sig { params(text: T.nilable(String)).returns(Organization::PrivateRelation) }
  def self.search(text)
    if text.present?
      joins(:user).where("users.email = ? OR users.phone_number = ? OR organizations.name ILIKE ?",
                         text, text, "%#{text}%")
    else
      none
    end
  end

  sig { returns(Integer) }
  def self.name_max_length
    @name_max_length ||= T.let(columns.find { |c| c.name == "name" }.limit || 60, T.nilable(Integer))
  end

  sig { returns(Integer) }
  def self.responsible_name_max_length
    @responsible_name_max_length ||= T.let(
      columns.find { |c| c.name == "responsible_name" }.limit || 60,
      T.nilable(Integer)
    )
  end

  private

    sig { void }
    def validate_name_length
      validator = ActiveModel::Validations::LengthValidator.new(
        attributes: :name,
        maximum: Organization.name_max_length
      )
      validator.validate(self)
    end

    sig { void }
    def validate_responsible_name_length
      validator = ActiveModel::Validations::LengthValidator.new(
        attributes: :responsible_name,
        maximum: Organization.responsible_name_max_length
      )
      validator.validate(self)
    end
end
