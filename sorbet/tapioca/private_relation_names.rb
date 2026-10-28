# typed: strict
# frozen_string_literal: true

# Signatures can use `Model::PrivateRelation` & co. because
# config/initializers/00_sorbet.rb aliases them to the relation classes Rails
# generates. When Tapioca turns these signatures into RBIs, it gets the runtime
# names (`Model::ActiveRecord_Relation`), which don't exist for Sorbet, so we
# translate them back.
module PrivateRelationNames
  extend T::Sig

  NAMES = T.let(
    {
      "ActiveRecord_Relation" => "PrivateRelation",
      "ActiveRecord_AssociationRelation" => "PrivateAssociationRelation",
      "ActiveRecord_Associations_CollectionProxy" => "PrivateCollectionProxy"
    }.freeze,
    T::Hash[String, String]
  )

  PATTERN = T.let(/::(#{NAMES.keys.join("|")})\b/, Regexp)

  sig { params(name: String).returns(String) }
  def self.translate(name)
    name.gsub(PATTERN) { "::#{NAMES.fetch(T.must(Regexp.last_match(1)))}" }
  end

  # Return types
  module Reflection
    extend T::Sig

    sig { params(type: T::Types::Base).returns(String) }
    def name_of_type(type)
      PrivateRelationNames.translate(super)
    end
  end

  # Parameter types
  module Compiler
    extend T::Sig

    sig { params(method_def: T.any(Method, UnboundMethod), signature: T.untyped).returns(T::Array[String]) }
    def parameters_types_from_signature(method_def, signature)
      super.map { |type| PrivateRelationNames.translate(type) }
    end
  end
end

Tapioca::Runtime::Reflection.prepend(PrivateRelationNames::Reflection)
Tapioca::Dsl::Compiler.prepend(PrivateRelationNames::Compiler)
