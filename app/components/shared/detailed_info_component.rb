# typed: strict
class Shared::DetailedInfoComponent < ApplicationComponent
  Record = T.type_alias { T.any(Debate, Proposal, Budget::Investment, Legislation::Proposal, Topic) }

  sig { returns(Record) }
  attr_reader :record

  sig { returns(String) }
  attr_reader :comments_path

  sig { returns(T::Boolean) }
  attr_reader :preview

  alias_method :preview?, :preview

  sig { params(record: Record, comments_path: String, preview: T::Boolean).void }
  def initialize(record, comments_path: "#comments", preview: false)
    @record = record
    @comments_path = comments_path
    @preview = preview
  end

  private

    sig { returns(ActiveSupport::SafeBuffer) }
    def date
      time_tag record.created_at.to_date, format: :default
    end
end
