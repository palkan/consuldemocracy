# typed: strict
class Legislation::Process::Phase
  extend T::Sig

  sig { params(start_date: T.nilable(Date), end_date: T.nilable(Date), enabled: T.nilable(T::Boolean)).void }
  def initialize(start_date, end_date, enabled)
    @start_date = start_date
    @end_date = end_date
    @enabled = enabled
  end

  sig { returns(T.nilable(T::Boolean)) }
  def enabled?
    @enabled
  end

  sig { returns(T.nilable(T::Boolean)) }
  def started?
    enabled? && Date.current >= T.must(@start_date)
  end

  sig { returns(T.nilable(T::Boolean)) }
  def open?
    started? && Date.current <= T.must(@end_date)
  end
end
