# typed: strict
class LocalCensus
  extend T::Sig
  include DocumentParser

  sig do
    params(
      document_type: T.nilable(T.any(String, Integer)),
      document_number: T.nilable(T.any(String, Integer))
    ).returns(T.nilable(Response))
  end
  def call(document_type, document_number)
    record = T.let(nil, T.nilable(Response))
    get_document_number_variants(document_type, document_number).each do |variant|
      record = Response.new(get_record(document_type, variant))
      return record if record.valid?
    end
    record
  end

  class Response
    extend T::Sig

    sig { params(body: T.nilable(LocalCensusRecord)).void }
    def initialize(body)
      @body = body
    end

    sig { returns(T::Boolean) }
    def valid?
      body = @body
      body.present? ? !body.attributes.values.include?("") : false
    end

    sig { returns(T.nilable(Date)) }
    def date_of_birth
      T.must(@body).date_of_birth
    end

    sig { returns(T.nilable(String)) }
    def postal_code
      T.must(@body).postal_code
    end

    # Local census records don't have these attributes unless an installation adds them
    sig { returns(T.untyped) }
    def district_code
      T.unsafe(@body).district_code
    rescue
      nil
    end

    sig { returns(T.nilable(String)) }
    def gender
      case T.unsafe(@body).gender
      when "Varón"
        "male"
      when "Mujer"
        "female"
      end
    rescue NoMethodError
      nil
    end

    sig { returns(T.nilable(String)) }
    def name
      "#{T.unsafe(@body).nombre} #{T.unsafe(@body).apellido1}"
    rescue
      nil
    end

    private

      sig { returns(T::Hash[String, T.untyped]) }
      def data
        T.must(@body).attributes
      end
  end

  private

    sig do
      params(
        document_type: T.nilable(T.any(String, Integer)),
        document_number: String
      ).returns(T.nilable(LocalCensusRecord))
    end
    def get_record(document_type, document_number)
      LocalCensusRecord.find_by(document_type: document_type, document_number: document_number)
    end
end
