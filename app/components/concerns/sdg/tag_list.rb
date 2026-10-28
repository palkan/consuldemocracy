# typed: strict
module SDG::TagList
  extend ActiveSupport::Concern
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ApplicationComponent }

  sig { returns(T.untyped) }
  attr_reader :record

  sig { returns(T.nilable(Integer)) }
  attr_reader :limit

  sig { params(record: T.untyped, limit: T.nilable(Integer)).void }
  def initialize(record, limit: nil)
    @record = record
    @limit = limit
  end

  sig { returns(T.nilable(T::Boolean)) }
  def render?
    SDG::ProcessEnabled.new(record).enabled?
  end

  sig { returns(T::Enumerable[T.untyped]) }
  def tag_records
    tags = record.send(association_name)

    if tags.respond_to?(:limit)
      tags.order(:code).limit(limit)
    else
      tags.sort[0..(limit.to_i - 1)]
    end
  end

  sig { returns(ActiveSupport::SafeBuffer) }
  def see_more_link
    render Shared::SeeMoreLinkComponent.new(record, association_name, limit: limit)
  end

  sig { returns(Symbol) }
  def association_name
    raise NotImplementedError, "method must be implemented in the included class"
  end
end
