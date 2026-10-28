# typed: strict
class Shared::DateOfBirthFieldComponent < ApplicationComponent
  sig { returns(ActionView::Helpers::FormBuilder) }
  attr_reader :form

  sig { returns(T::Hash[Symbol, T.untyped]) }
  attr_reader :options

  sig { params(form: ActionView::Helpers::FormBuilder, options: T.untyped).void }
  def initialize(form, **options)
    @form = form
    @options = options
  end

  private

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def default_options
      {
        min: "1900-01-01",
        max: minimum_required_age.years.ago
      }
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def field_options
      default_options.merge(options)
    end

    sig { returns(Integer) }
    def minimum_required_age
      User.minimum_required_age
    end
end
