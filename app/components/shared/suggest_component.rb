# typed: strict
class Shared::SuggestComponent < ApplicationComponent
  sig { returns(T.untyped) }
  attr_reader :resources

  sig { returns(T.nilable(String)) }
  attr_reader :search_terms

  sig { params(resources: T.untyped, search_terms: T.nilable(String), resource_name: T.nilable(String)).void }
  def initialize(resources, search_terms:, resource_name: nil)
    @resources = resources
    @search_terms = search_terms
    @resource_name = resource_name
    @suggestions = T.let(nil, T.untyped)
  end

  sig { returns(T.nilable(T::Boolean)) }
  def render?
    search_terms && suggestions.any?
  end

  sig { returns(String) }
  def resource_name
    @resource_name ||= resource_model.to_s.parameterize(separator: "_")
  end

  private

    sig { returns(Integer) }
    def limit
      5
    end

    sig { returns(T.untyped) }
    def suggestions
      @suggestions ||= resources.search(search_terms)
    end

    sig { returns(T.class_of(ApplicationRecord)) }
    def resource_model
      resources.first.class
    end
end
