# typed: strict
module Types
  class BaseObject < GraphQL::Schema::Object
    extend T::Sig

    sig do
      params(
        name_positional: T.nilable(T.any(Symbol, String)),
        type_positional: T.untyped,
        desc_positional: T.nilable(String),
        kwargs: T.untyped,
        "&": T.nilable(T.proc.params(field: GraphQL::Schema::Field).bind(GraphQL::Schema::Field).void)
      ).returns(T.nilable(Symbol))
    end
    def self.field(name_positional = nil, type_positional = nil, desc_positional = nil, **kwargs, &)
      super

      # The old api contained non-camelized fields
      # We want to support these for now, but throw a deprecation warning
      #
      # Example:
      # proposal_notifications => Deprecation warning (Old api)
      # proposalNotifications => No deprecation warning (New api)
      field_name = name_positional

      if field_name.to_s.include?("_")
        reason = "Snake case fields are deprecated. Please use #{field_name.to_s.camelize(:lower)}."
        super(name_positional, type_positional, desc_positional,
              **kwargs.merge({ camelize: false, deprecation_reason: reason }), &)
      end

      # Make sure associations only return public records
      # by automatically calling 'public_for_api'
      type_class = type_positional

      if type_class.is_a?(Class) && type_class.ancestors.include?(GraphQL::Types::Relay::BaseConnection)
        define_method(T.must(field_name)) do
          T.bind(self, BaseObject)
          object.send(T.must(field_name)).public_for_api
        end
      end
    end

    sig do
      params(
        field_name: Symbol,
        type: T.untyped,
        description: String,
        null: T::Boolean
      ).returns(T.nilable(Symbol))
    end
    def self.object_by_id_field(field_name, type, description, null:)
      field field_name, type, description, null: null do
        argument :id, ID, required: true, default_value: false
      end
    end

    sig do
      params(
        field_name: Symbol,
        type: T.untyped,
        description: T.nilable(String),
        "**": T.untyped,
        "&": T.nilable(T.proc.params(field: GraphQL::Schema::Field).bind(GraphQL::Schema::Field).void)
      ).returns(T.nilable(Symbol))
    end
    def self.collection_field(field_name, type, description = nil, **, &)
      field(field_name, type.connection_type, description, **, &)
    end
  end
end
