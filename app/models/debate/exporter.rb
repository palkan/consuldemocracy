# typed: strict
class Debate::Exporter
  include CsvExporter
  extend T::Sig

  sig { returns(T::Enumerable[Debate]) }
  attr_reader :records

  sig { params(debates: T::Enumerable[Debate]).void }
  def initialize(debates)
    @records = debates
  end

  private

    sig { returns(T::Array[String]) }
    def model_headers
      [
        I18n.t("admin.debates.index.id"),
        Debate.human_attribute_name(:title),
        I18n.t("admin.debates.index.author"),
        Debate.human_attribute_name(:created_at)
      ]
    end

    sig { params(debate: Debate).returns(T::Array[T.nilable(String)]) }
    def record_csv_values(debate)
      [
        debate.id.to_s,
        debate.title,
        T.must(debate.author).email,
        I18n.l(debate.created_at, format: :datetime)
      ]
    end
end
