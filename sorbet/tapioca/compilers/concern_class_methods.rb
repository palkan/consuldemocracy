# typed: strict
# frozen_string_literal: true

module Tapioca
  module Dsl
    module Compilers
      # Sorbet doesn't know that including a concern (or a module with a
      # `self.included` hook that extends `ClassMethods`) also extends the
      # base with the concern's own `ClassMethods` module. Tapioca's
      # `ActiveSupportConcern` compiler only declares the `ClassMethods` of
      # the concern's dependencies, so we declare the concern's own module here.
      class ConcernClassMethods < Compiler
        extend T::Sig

        ConstantType = type_member { { fixed: Module } }

        sig { override.void }
        def decorate
          root.create_path(constant) do |mod|
            mod.create_mixes_in_class_methods("#{qualified_name_of(constant)}::ClassMethods")
          end
        end

        class << self
          extend T::Sig

          sig { override.returns(T::Enumerable[Module]) }
          def gather_constants
            app_root = Rails.root.join("app").to_s

            all_modules.select do |mod|
              name = name_of(mod)
              next false if name.nil? || mod.is_a?(Class) || mod.singleton_class?
              next false unless mod.const_defined?(:ClassMethods, false)

              location = Object.const_source_location(name)&.first
              location&.start_with?(app_root)
            end
          end
        end
      end
    end
  end
end
