# typed: strict
class SDGManagement::Relations::EditComponent < ApplicationComponent
  include Header

  sig { returns(T.untyped) }
  attr_reader :record

  sig { params(record: T.untyped).void }
  def initialize(record)
    @record = record
  end

  private

    sig { override.returns(T.nilable(String)) }
    def title
      @record.title
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def update_path
      {
        controller: "sdg_management/relations",
        action: :update,
        relatable_type: record.class.name.tableize,
        id: record
      }
    end
end
