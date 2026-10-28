# typed: strict
class Admin::AllowedTableActionsComponent < ApplicationComponent
  sig { returns(T.untyped) }
  attr_reader :record

  sig { returns(T::Hash[Symbol, T.untyped]) }
  attr_reader :options

  delegate :action, to: :table_actions_component

  sig { params(record: T.untyped, options: T.untyped).void }
  def initialize(record, **options)
    @record = record
    @options = options
    @table_actions_component = T.let(nil, T.nilable(Admin::TableActionsComponent))
  end

  private

    sig { returns(T::Array[Symbol]) }
    def actions
      (options[:actions] || [:edit, :destroy]).select { |action| can?(action, record) }
    end

    sig { returns(Admin::TableActionsComponent) }
    def table_actions_component
      @table_actions_component ||= Admin::TableActionsComponent.new(record, **options, actions: actions)
    end
end
