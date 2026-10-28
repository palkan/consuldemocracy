# typed: strict
module Translatable
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ActionController::Base }

  private

    sig do
      params(resource_model: T.untyped, options: T::Hash[Symbol, T.untyped])
        .returns(T::Hash[Symbol, T::Array[Symbol]])
    end
    def translation_params(resource_model, options = {})
      attributes = [:id, :locale, :_destroy]
      if options[:only]
        attributes += Array(options[:only])
      else
        attributes += resource_model.translated_attribute_names
      end
      { translations_attributes: attributes - Array(options[:except]) }
    end
end
