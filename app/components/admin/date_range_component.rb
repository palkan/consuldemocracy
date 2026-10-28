# typed: strict
class Admin::DateRangeComponent < ApplicationComponent
  DateOrTime = T.type_alias { T.nilable(T.any(ActiveSupport::TimeWithZone, Time, Date)) }

  sig { returns(DateOrTime) }
  attr_reader :start_time, :end_time

  sig { params(start_time: DateOrTime, end_time: DateOrTime).void }
  def initialize(start_time, end_time)
    @start_time = start_time
    @end_time = end_time
  end

  sig { returns(ActiveSupport::SafeBuffer) }
  def call
    safe_join([formatted_start_time, "-", formatted_end_time], " ")
  end

  private

    sig { returns(T.nilable(ActiveSupport::SafeBuffer)) }
    def formatted_start_time
      formatted_date(start_time) if start_time.present?
    end

    sig { returns(T.nilable(ActiveSupport::SafeBuffer)) }
    def formatted_end_time
      formatted_date(end_time) if end_time.present?
    end

    sig { params(time: DateOrTime).returns(ActiveSupport::SafeBuffer) }
    def formatted_date(time)
      time_tag(time, format: :short_datetime)
    end
end
