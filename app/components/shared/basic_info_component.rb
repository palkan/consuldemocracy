# typed: strict
class Shared::BasicInfoComponent < ApplicationComponent
  sig { returns(T.any(Debate, Proposal, Budget::Investment, Legislation::Proposal, Topic)) }
  attr_reader :record

  delegate :namespace, to: :helpers

  sig { params(record: T.any(Debate, Proposal, Budget::Investment, Legislation::Proposal, Topic)).void }
  def initialize(record)
    @record = record
  end

  private

    sig { returns(String) }
    def comments_path
      if namespace == "management"
        management_polymorphic_path(record, anchor: "comments")
      else
        polymorphic_path(record, anchor: "comments")
      end
    end

    sig { returns(ActiveSupport::SafeBuffer) }
    def date
      time_tag record.created_at.to_date, format: :default
    end
end
