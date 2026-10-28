# typed: strict
module Globalizable
  MIN_TRANSLATIONS = 1
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ApplicationRecord }

  included do
    globalize_accessors
    accepts_nested_attributes_for :translations, allow_destroy: true

    validate :check_translations_number, on: :update, if: :translations_required?
    before_validation :assign_stashed_translations, on: :update
    after_validation :relocate_direct_translation_errors, on: :update
    after_validation :copy_error_to_current_translation, on: :update

    if paranoid? && translation_class.attribute_names.include?("hidden_at")
      translation_class.send :acts_as_paranoid, column: :hidden_at
    end
  end

  sig { returns(T::Array[Symbol]) }
  def locales_not_marked_for_destruction
    translations.reject(&:marked_for_destruction?).map(&:locale)
  end

  sig { returns(T::Array[Symbol]) }
  def locales_persisted_and_marked_for_destruction
    translations.select { |t| t.persisted? && t.marked_for_destruction? }.map(&:locale)
  end

  sig { returns(T::Boolean) }
  def translations_required?
    translated_attribute_names.any? { |attr| required_attribute?(attr) }
  end

  module ClassMethods
    extend T::Helpers
    extend T::Sig

    requires_ancestor { T.class_of(ApplicationRecord) }

    sig { params(method: Symbol, options: T::Hash[Symbol, T.untyped]).void }
    def validates_translation(method, options = {})
      validates(method, options.merge(if: lambda { |resource| resource.translations.blank? }))
      if options.include?(:length)
        translation_class.instance_eval do
          validates method,
                    length: options[:length],
                    if: lambda { |translation| translation.locale == Setting.default_locale }
        end
        if options.many?
          translation_class.instance_eval do
            validates method, options.reject { |key| key == :length }
          end
        end
      else
        translation_class.instance_eval { validates method, options }
      end
    end

    sig { params(method: Symbol).void }
    def translation_class_delegate(method)
      translation_class.instance_eval { delegate method, to: :globalized_model }
    end

    sig { returns(ActiveRecord::Relation) }
    def with_fallback_translation
      translations_foreign_key = reflect_on_association(:translations).foreign_key
      fallbacks = Globalize.fallbacks(Globalize.locale)

      translations_ids = translation_class
                         .select("DISTINCT ON (#{translations_foreign_key}) id")
                         .where(locale: fallbacks)
                         .order(translations_foreign_key)
                         .in_order_of(:locale, fallbacks)

      with_translations(fallbacks).where("#{translations_table_name}.id": translations_ids)
    end
  end

  private

    sig { params(attribute: Symbol).returns(T::Boolean) }
    def required_attribute?(attribute)
      T.cast(self.class, T.class_of(ApplicationRecord)).validators_on(attribute).any? do |validator|
        validator.kind == :presence && !conditional_validator?(validator)
      end
    end

    # Returns the value of the `unless` option of the validator, which can be any object
    sig { params(validator: ActiveModel::Validator).returns(T.untyped) }
    def conditional_validator?(validator)
      return false unless validator.options[:unless]

      if validator.options[:unless].to_proc.arity.zero?
        instance_exec(&validator.options[:unless])
      else
        validator.options[:unless].to_proc.call(self)
      end
    end

    sig { void }
    def check_translations_number
      errors.add(:base, :translations_too_short) unless traslations_count_valid?
    end

    sig { returns(T::Boolean) }
    def traslations_count_valid?
      translations.reject(&:marked_for_destruction?).count >= MIN_TRANSLATIONS
    end

    sig { void }
    def assign_stashed_translations
      @directly_edited_translation = T.let(nil, T.nilable(Globalize::ActiveRecord::Translation))

      globalize.stash.each do |locale, attributes|
        next if attributes.blank?

        translation = translation_for(locale)
        @directly_edited_translation = translation if locale.to_s == I18n.locale.to_s
        attributes.each { |name, value| translation[name] = value }
      end
    end

    sig { void }
    def relocate_direct_translation_errors
      return unless @directly_edited_translation

      translation = @directly_edited_translation
      @directly_edited_translation = nil

      copied_errors = errors.objects.select do |error|
        error.is_a?(ActiveModel::NestedError) && error.inner_error.base.equal?(translation)
      end

      translation.errors.reject { |error| error.attribute == :base }.each do |error|
        errors.import(error, attribute: error.attribute)
      end

      copied_errors.reject do |error|
        T.cast(error, ActiveModel::NestedError).inner_error.attribute == :base
      end.each do |error|
        errors.objects.delete(error)
      end
    end

    sig { void }
    def copy_error_to_current_translation
      return unless errors.added?(:base, :translations_too_short)

      if locales_persisted_and_marked_for_destruction.include?(I18n.locale)
        locale = I18n.locale
      else
        locale = locales_persisted_and_marked_for_destruction.first
      end

      translation = translation_for(locale)
      translation.errors.add(:base, :translations_too_short)
    end

    sig { returns(T::Hash[T.untyped, String]) }
    def searchable_globalized_values
      values = {}
      translations.each do |translation|
        Globalize.with_locale(translation.locale) do
          values.merge! searchable_translations_definitions
        end
      end
      values
    end
end
