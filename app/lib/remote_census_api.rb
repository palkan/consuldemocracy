# typed: strict
class RemoteCensusApi
  extend T::Sig
  include DocumentParser

  sig do
    params(
      document_type: T.nilable(T.any(String, Integer)),
      document_number: T.nilable(T.any(String, Integer)),
      date_of_birth: T.nilable(Date),
      postal_code: T.nilable(String)
    ).returns(T.nilable(Response))
  end
  def call(document_type, document_number, date_of_birth, postal_code)
    response = T.let(nil, T.nilable(Response))
    get_document_number_variants(document_type, document_number).each do |variant|
      response = Response.new(get_response_body(document_type, variant, date_of_birth, postal_code))
      return response if response.valid?
    end
    response
  end

  class Response
    extend T::Sig

    sig { params(body: T::Hash[T.untyped, T.untyped]).void }
    def initialize(body)
      @body = body
    end

    sig { params(path_value: T.nilable(String)).returns(T.untyped) }
    def extract_value(path_value)
      path = parse_response_path(path_value)
      return nil if path.blank?

      T.unsafe(@body).dig(*path)
    end

    sig { returns(T::Boolean) }
    def valid?
      path_value = Setting["remote_census.response.valid"]
      extract_value(path_value).present?
    end

    sig { returns(T.nilable(Date)) }
    def date_of_birth
      path_value = Setting["remote_census.response.date_of_birth"]
      str = extract_value(path_value)
      return nil if str.blank?

      day, month, year = str.match(/(\d\d?)\D(\d\d?)\D(\d\d\d?\d?)/)[1..3]
      return nil if day.blank? || month.blank? || year.blank?

      Time.zone.local(year.to_i, month.to_i, day.to_i).to_date
    end

    sig { returns(T.untyped) }
    def postal_code
      path_value = Setting["remote_census.response.postal_code"]
      extract_value(path_value)
    end

    sig { returns(T.untyped) }
    def district_code
      path_value = Setting["remote_census.response.district"]
      extract_value(path_value)
    end

    sig { returns(T.nilable(String)) }
    def gender
      path_value = Setting["remote_census.response.gender"]

      case extract_value(path_value)
      when "Male", "Varón"
        "male"
      when "Female", "Mujer"
        "female"
      end
    end

    sig { returns(String) }
    def name
      path_value_name = Setting["remote_census.response.name"]
      path_value_surname = Setting["remote_census.response.surname"]

      "#{extract_value(path_value_name)} #{extract_value(path_value_surname)}"
    end

    sig { params(path_value: T.nilable(String)).returns(T.nilable(T::Array[Symbol])) }
    def parse_response_path(path_value)
      path_value.split(".").map(&:to_sym) if path_value.present?
    end
  end

  private

    sig do
      params(
        document_type: T.nilable(T.any(String, Integer)),
        document_number: String,
        date_of_birth: T.nilable(Date),
        postal_code: T.nilable(String)
      ).returns(T::Hash[T.untyped, T.untyped])
    end
    def get_response_body(document_type, document_number, date_of_birth, postal_code)
      if end_point_defined?
        request = request(document_type, document_number, date_of_birth, postal_code)
        client.call(T.must(Setting["remote_census.request.method_name"]).to_sym, message: request).body
      else
        stubbed_invalid_response
      end
    end

    sig { returns(Savon::Client) }
    def client
      @client = T.let(Savon.client(wsdl: Setting["remote_census.general.endpoint"]), T.nilable(Savon::Client))
      T.must(@client)
    end

    sig do
      params(
        document_type: T.nilable(T.any(String, Integer)),
        document_number: String,
        date_of_birth: T.nilable(Date),
        postal_code: T.nilable(String)
      ).returns(T.untyped)
    end
    def request(document_type, document_number, date_of_birth, postal_code)
      structure = JSON.parse(T.must(Setting["remote_census.request.structure"]))

      fill_in(structure, Setting["remote_census.request.document_type"], document_type)
      fill_in(structure, Setting["remote_census.request.document_number"], document_number)
      fill_in(structure, Setting["remote_census.request.postal_code"], postal_code)
      if date_of_birth.present?
        fill_in(structure,
                Setting["remote_census.request.date_of_birth"],
                I18n.l(date_of_birth, format: :default))
      end

      structure
    end

    sig { params(structure: T.untyped, path_value: T.nilable(String), value: T.untyped).void }
    def fill_in(structure, path_value, value)
      path = parse_request_path(path_value)
      update_value(structure, path, value) if path.present?
    end

    sig { params(path_value: T.nilable(String)).returns(T.nilable(T::Array[String])) }
    def parse_request_path(path_value)
      path_value.presence&.split(".")
    end

    sig { params(structure: T.untyped, path: T::Array[String], value: T.untyped).void }
    def update_value(structure, path, value)
      *path, final_key = path
      to_set = path.empty? ? structure : structure.dig(*path)

      return unless to_set

      to_set[final_key] = value
    end

    sig { returns(T::Boolean) }
    def end_point_defined?
      Setting["remote_census.general.endpoint"].present?
    end

    sig { returns(T::Hash[T.untyped, T.untyped]) }
    def stubbed_invalid_response
      {}
    end
end
