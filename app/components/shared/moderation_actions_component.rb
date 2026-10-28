# typed: strict
class Shared::ModerationActionsComponent < ApplicationComponent
  sig { returns(T.untyped) }
  attr_reader :record

  sig { params(record: T.untyped).void }
  def initialize(record)
    @record = record
  end

  sig { returns(T::Boolean) }
  def render?
    can?(:hide, record) || can?(:hide, author)
  end

  private

    sig { returns(T.nilable(User)) }
    def author
      record.author
    end

    sig { returns(String) }
    def hide_path
      polymorphic_path([:moderation, record], action: :hide)
    end
end
