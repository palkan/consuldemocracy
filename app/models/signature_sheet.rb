# typed: strict
class SignatureSheet < ApplicationRecord
  belongs_to :signable, polymorphic: true
  belongs_to :author, class_name: "User"

  VALID_SIGNABLES = %w[Proposal Budget::Investment].freeze

  has_many :signatures

  validates :author, presence: true
  validates :signable_type, inclusion: { in: ->(*) { VALID_SIGNABLES }}
  validates :required_fields_to_verify, presence: true
  validates :signable, presence: true
  validate  :signable_found

  sig { returns(String) }
  def name
    if title.present?
      "#{signable_name} #{signable_id}: #{title}"
    else
      "#{signable_name} #{signable_id}"
    end
  end

  sig { returns(String) }
  def signable_name
    I18n.t("activerecord.models.#{T.must(signable_type).underscore}", count: 1)
  end

  sig { void }
  def verify_signatures
    parsed_required_fields_to_verify_groups.each do |required_fields_to_verify|
      document_number = required_fields_to_verify[0]
      date_of_birth = parse_date_of_birth(required_fields_to_verify)
      postal_code = parse_postal_code(required_fields_to_verify)

      signature = signatures.where(document_number: document_number,
                                   date_of_birth: date_of_birth,
                                   postal_code: postal_code).first_or_create!
      signature.verify
    end
    update!(processed: true)
  end

  sig { returns(T::Array[T::Array[String]]) }
  def parsed_required_fields_to_verify_groups
    T.must(required_fields_to_verify).split(";")
                                     .map { |d| d.gsub(/\s+/, "") }
                                     .map { |group| group.split(",") }
  end

  sig { void }
  def signable_found
    errors.add(:signable_id, :not_found) if errors.messages[:signable].present?
  end

  private

    sig { params(required_fields_to_verify: T::Array[String]).returns(T.nilable(String)) }
    def parse_date_of_birth(required_fields_to_verify)
      return required_fields_to_verify[1] if Setting.force_presence_date_of_birth?

      nil
    end

    sig { params(required_fields_to_verify: T::Array[String]).returns(T.nilable(String)) }
    def parse_postal_code(required_fields_to_verify)
      if Setting.force_presence_date_of_birth? && Setting.force_presence_postal_code?
        required_fields_to_verify[2]
      elsif Setting.force_presence_postal_code?
        required_fields_to_verify[1]
      else
        nil
      end
    end
end
