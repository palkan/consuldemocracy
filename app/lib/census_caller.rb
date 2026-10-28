# typed: strict
class CensusCaller
  extend T::Sig

  AnyResponse = T.type_alias do
    T.any(CensusApi::Response, RemoteCensusApi::Response, LocalCensus::Response, CensusCaller::Response)
  end

  sig do
    params(
      document_type: T.nilable(T.any(String, Integer)),
      document_number: T.nilable(T.any(String, Integer)),
      date_of_birth: T.nilable(Date),
      postal_code: T.nilable(String)
    ).returns(AnyResponse)
  end
  def call(document_type, document_number, date_of_birth, postal_code)
    return Response.new if document_number.blank? || document_type.blank?

    if Setting["feature.remote_census"].present?
      response = RemoteCensusApi.new.call(document_type, document_number, date_of_birth, postal_code)
    else
      response = CensusApi.new.call(document_type, document_number)
    end
    response = LocalCensus.new.call(document_type, document_number) unless T.must(response).valid?

    T.must(response)
  end

  class Response
    extend T::Sig

    sig { returns(T::Boolean) }
    def valid?
      false
    end
  end
end
