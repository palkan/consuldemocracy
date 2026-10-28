# typed: strict
module SkipValidation
  extend ActiveSupport::Concern

  module ClassMethods
    extend T::Helpers
    extend T::Sig

    requires_ancestor { T.class_of(ActiveRecord::Base) }

    sig { params(field: Symbol, validator: T.any(T::Class[ActiveModel::Validator], Symbol, String)).void }
    def skip_validation(field, validator)
      validator_class = if validator.is_a?(Class)
                          validator
                        else
                          "ActiveModel::Validations::#{validator.to_s.camelize}Validator".constantize
                        end

      _validators[field].reject! { |existing_validator| existing_validator.is_a?(validator_class) }

      _validate_callbacks.each do |callback|
        if callback.filter.is_a?(validator_class)
          callback.filter.instance_variable_set(:@attributes, callback.filter.attributes - [field])
        end
      end
    end

    sig { params(field: Symbol, validator: T.any(T::Class[ActiveModel::Validator], Symbol, String)).void }
    def skip_translation_validation(field, validator)
      skip_validation(field, validator)
      T.cast(self, Globalize::ActiveRecord::ClassMethods).translation_class.skip_validation(field, validator)
    end
  end
end
