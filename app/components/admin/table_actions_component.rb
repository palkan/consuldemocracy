# typed: strict
class Admin::TableActionsComponent < ApplicationComponent
  sig { returns(T.untyped) }
  attr_reader :record

  sig { returns(T::Hash[Symbol, T.untyped]) }
  attr_reader :options

  sig { params(record: T.untyped, options: T.untyped).void }
  def initialize(record, **options)
    @record = record
    @options = options
  end

  sig { params(action_name: Symbol, "**": T.untyped).returns(ActiveSupport::SafeBuffer) }
  def action(action_name, **)
    render Admin::ActionComponent.new(action_name, record, "aria-label": true, **)
  end

  private

    sig { returns(T::Array[Symbol]) }
    def actions
      options[:actions] || [:edit, :destroy]
    end

    sig { returns(T.untyped) }
    def edit_text
      options[:edit_text]
    end

    sig { returns(T.untyped) }
    def edit_path
      options[:edit_path]
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def edit_options
      options[:edit_options] || {}
    end

    sig { returns(T.untyped) }
    def destroy_text
      options[:destroy_text]
    end

    sig { returns(T.untyped) }
    def destroy_path
      options[:destroy_path]
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def destroy_options
      {
        confirm: options[:destroy_confirmation] || true
      }.merge(options[:destroy_options] || {})
    end
end
