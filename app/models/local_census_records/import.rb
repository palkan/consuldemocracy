# typed: strict
class LocalCensusRecords::Import
  extend T::Sig
  include ActiveModel::Model

  ATTRIBUTES = %w[document_type document_number date_of_birth postal_code].freeze
  ALLOWED_FILE_EXTENSIONS = %w[csv].freeze

  sig { returns(T.untyped) }
  attr_accessor :file

  sig { returns(T::Array[LocalCensusRecord]) }
  attr_accessor :created_records, :invalid_records

  validates :file, presence: true
  validate :file_extension, if: -> { T.bind(self, LocalCensusRecords::Import).file.present? }
  validate :file_headers_definition, if: -> do
    T.bind(self, LocalCensusRecords::Import)
    file.present? && valid_extension?
  end

  sig { params(attributes: T.untyped).void }
  def initialize(attributes = {})
    if attributes.present?
      attributes.each do |attr, value|
        public_send("#{attr}=", value)
      end
    end
    @created_records = T.let([], T::Array[LocalCensusRecord])
    @invalid_records = T.let([], T::Array[LocalCensusRecord])
  end

  sig { returns(T::Boolean) }
  def save
    return false if invalid?

    CSV.open(file.path, headers: true).each do |row|
      next if empty_row?(row)

      process_row row
    end
    true
  end

  sig { returns(T.nilable(T::Boolean)) }
  def save!
    validate! && save
  end

  private

    sig { params(row: CSV::Row).void }
    def process_row(row)
      local_census_record = build_local_census_record(row)

      if local_census_record.invalid?
        invalid_records << local_census_record
      else
        local_census_record.save!
        created_records << local_census_record
      end
    end

    sig { params(row: CSV::Row).returns(LocalCensusRecord) }
    def build_local_census_record(row)
      local_census_record = LocalCensusRecord.new
      local_census_record.attributes = row.to_hash.slice(*ATTRIBUTES)
      local_census_record
    end

    sig { params(row: CSV::Row).returns(T::Boolean) }
    def empty_row?(row)
      row.all? { |_, cell| cell.nil? }
    end

    sig { void }
    def file_extension
      return if valid_extension?

      errors.add :file, :extension, valid_extensions: ALLOWED_FILE_EXTENSIONS.join(", ")
    end

    sig { returns(T.untyped) }
    def fetch_file_headers
      CSV.open(file.path, &:readline)
    end

    sig { void }
    def file_headers_definition
      headers = fetch_file_headers
      return if headers.all? { |header| ATTRIBUTES.include? header } &&
                ATTRIBUTES.all? { |attr| headers.include? attr }

      errors.add :file, :headers, required_headers: ATTRIBUTES.join(", ")
    end

    sig { returns(T::Boolean) }
    def valid_extension?
      ALLOWED_FILE_EXTENSIONS.include? extension
    end

    sig { returns(String) }
    def extension
      File.extname(file.original_filename).delete(".")
    end
end
