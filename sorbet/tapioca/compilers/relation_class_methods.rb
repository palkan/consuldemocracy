# typed: strict
# frozen_string_literal: true

require_relative "../private_relation_names"

module Tapioca
  module Dsl
    module Compilers
      # Active Record relations delegate missing methods to the model class, so
      # `Proposal.published.search(terms)` calls `Proposal.search`. Tapioca only
      # declares scopes on relations, so we copy the class methods defined in
      # `app/` (on the model itself or in a concern's `ClassMethods` module),
      # with their signatures, to the generated relation modules.
      class RelationClassMethods < Compiler
        extend T::Sig

        ConstantType = type_member { { fixed: T.class_of(ActiveRecord::Base) } }

        # Relation module => the model's relation class that methods in it return
        RELATION_MODULES = T.let(
          {
            "GeneratedRelationMethods" => "PrivateRelation",
            "GeneratedAssociationRelationMethods" => "PrivateAssociationRelation"
          }.freeze,
          T::Hash[String, String]
        )

        sig { override.void }
        def decorate
          methods = class_methods
          return if methods.empty?

          model_name = T.must(qualified_name_of(constant))

          root.create_path(constant) do |model|
            RELATION_MODULES.each do |relation_module, relation_class|
              model.create_module(relation_module) do |mod|
                methods.each do |method|
                  create_relation_method(mod, method, "#{model_name}::#{relation_class}")
                end
              end
            end
          end
        end

        class << self
          extend T::Sig

          sig { override.returns(T::Enumerable[Module]) }
          def gather_constants
            descendants_of(ActiveRecord::Base).reject(&:abstract_class?).select { |model| name_of(model) }
          end
        end

        private

          sig { returns(T::Array[Method]) }
          def class_methods
            ancestors = constant.singleton_class.ancestors
              .take_while { |mod| mod != ActiveRecord::Base.singleton_class }

            names = ancestors.flat_map { |mod| mod.public_instance_methods(false) }.uniq

            names.filter_map do |name|
              method = constant.method(name)
              method if defined_in_app?(method) && typed?(method) && !relation_method?(name)
            end
          end

          # Methods without a signature (e.g. defined with `define_singleton_method`)
          # can be declared with a precise type in a shim
          sig { params(method: Method).returns(T::Boolean) }
          def typed?(method)
            !T::Utils.signature_for_method(method).nil?
          end

          sig { params(method: Method).returns(T::Boolean) }
          def defined_in_app?(method)
            signature = T::Utils.signature_for_method(method)
            location = (signature ? signature.method : method).source_location&.first

            !location.nil? && location.start_with?(Rails.root.join("app").to_s)
          end

          # Relations already have these methods, scopes included: on a relation,
          # a scope runs its body even if the model redefines the class method
          sig { params(name: Symbol).returns(T::Boolean) }
          def relation_method?(name)
            ActiveRecord::Relation.method_defined?(name) ||
              ActiveRecord::Relation.private_method_defined?(name) ||
              constant.send(:generated_relation_methods).method_defined?(name)
          end

          # Concerns can only declare that their class methods return an
          # `ActiveRecord::Relation`, but on a relation of this model they return
          # this model's relation class
          sig { params(mod: RBI::Scope, method: Method, relation_class: String).void }
          def create_relation_method(mod, method, relation_class)
            return_type = compile_method_return_type_to_rbi(method)
              .gsub(/(?<![\w:])::ActiveRecord::Relation(?![\w:])/, relation_class)
              .gsub("T.attached_class", T.must(qualified_name_of(constant)))
              .gsub("T.self_type", "T.untyped")

            mod.create_method(
              method.name.to_s,
              parameters: compile_method_parameters_to_rbi(method),
              return_type: return_type
            )
          end
      end
    end
  end
end
