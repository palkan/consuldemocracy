# typed: strict
class Shared::SearchResultsSummaryComponent < ApplicationComponent
  sig { returns(ActiveRecord::Relation) }
  attr_reader :results

  sig { returns(T.nilable(String)) }
  attr_reader :search_terms

  sig { returns(T.untyped) }
  attr_reader :advanced_search_terms

  sig do
    params(
      results: ActiveRecord::Relation,
      search_terms: T.nilable(String),
      advanced_search_terms: T.untyped
    ).void
  end
  def initialize(results:, search_terms:, advanced_search_terms:)
    @results = results
    @search_terms = search_terms
    @advanced_search_terms = advanced_search_terms
  end

  private

    sig { returns(T.nilable(ActiveSupport::SafeBuffer)) }
    def summary
      sanitize(t(
        "proposals.index.search_results",
        count: results.size,
        search_term: strip_tags(search_terms)
      ))
    end
end
