# typed: strict
class ImageSuggestions::SuggestionsComponent < ApplicationComponent
  sig { returns(T.untyped) }
  attr_reader :suggestions

  sig { params(suggestions: T.untyped).void }
  def initialize(suggestions)
    @suggestions = suggestions
  end

  private

    sig { returns(T::Array[T.untyped]) }
    def images
      suggestions.results.presence&.photos || []
    end

    sig { returns(T::Array[String]) }
    def errors
      suggestions.errors
    end

    sig { returns(String) }
    def error_messages
      errors.join(", ")
    end
end
