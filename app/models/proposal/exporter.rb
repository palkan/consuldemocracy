# typed: strict
class Proposal::Exporter
  include CsvExporter
  include JsonExporter
  extend T::Sig

  sig { returns(T::Enumerable[Proposal]) }
  attr_reader :records

  sig { params(proposals: T::Enumerable[Proposal]).void }
  def initialize(proposals)
    @records = proposals
  end

  sig { returns(T.class_of(Proposal)) }
  def model
    Proposal
  end

  private

    sig { params(proposal: Proposal).returns(T::Hash[Symbol, T.untyped]) }
    def json_values(proposal)
      {
        id: proposal.id,
        title: proposal.title,
        summary: strip_tags(proposal.summary),
        description: strip_tags(proposal.description)
      }
    end

    sig { returns(T::Array[String]) }
    def model_headers
      [
        I18n.t("admin.proposals.index.list.id"),
        I18n.t("admin.proposals.index.list.title"),
        I18n.t("admin.proposals.index.list.author"),
        I18n.t("admin.proposals.index.list.summary"),
        Proposal.human_attribute_name(:created_at)
      ]
    end

    sig { params(proposal: Proposal).returns(T::Array[T.nilable(String)]) }
    def record_csv_values(proposal)
      [
        proposal.id.to_s,
        proposal.title,
        T.must(proposal.author).email,
        proposal.summary,
        I18n.l(proposal.created_at, format: :datetime)
      ]
    end
end
