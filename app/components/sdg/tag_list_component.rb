# typed: strict
class SDG::TagListComponent < ApplicationComponent
  sig { returns(T.untyped) }
  attr_reader :record

  sig { returns(T.nilable(Integer)) }
  attr_reader :limit

  sig { returns(T::Boolean) }
  attr_reader :linkable

  sig { params(record: T.untyped, limit: T.nilable(Integer), linkable: T::Boolean).void }
  def initialize(record, limit: nil, linkable: true)
    @record = record
    @limit = limit
    @linkable = linkable
  end

  sig { returns(T::Boolean) }
  def render?
    record.sdg_goals.any? || record.sdg_targets.any?
  end

  private

    sig { returns(String) }
    def goals_list
      if linkable
        render SDG::Goals::TagListComponent.new(record, limit: limit)
      else
        render SDG::Goals::PlainTagListComponent.new(record, limit: limit)
      end
    end

    sig { returns(String) }
    def targets_list
      if linkable
        render SDG::Targets::TagListComponent.new(record, limit: limit)
      else
        render SDG::Targets::PlainTagListComponent.new(record, limit: limit)
      end
    end
end
