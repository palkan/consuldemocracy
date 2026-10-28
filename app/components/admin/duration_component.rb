# typed: strict
class Admin::DurationComponent < ApplicationComponent
  sig { returns(T.untyped) }
  attr_reader :durable

  sig { params(durable: T.untyped).void }
  def initialize(durable)
    @durable = durable
  end

  private

    sig { returns(ActiveSupport::SafeBuffer) }
    def dates
      render Admin::DateRangeComponent.new(start_time, end_time)
    end

    sig { returns(T.nilable(ActiveSupport::TimeWithZone)) }
    def start_time
      durable.starts_at
    end

    sig { returns(T.nilable(ActiveSupport::TimeWithZone)) }
    def end_time
      if durable.ends_at.present? && durable.ends_at == durable.ends_at.beginning_of_day
        durable.ends_at - 1.second
      else
        durable.ends_at
      end
    end
end
