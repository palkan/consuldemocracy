# typed: strict
module Age
  extend T::Sig

  sig do
    params(
      dob: T.nilable(T.any(Date, Time, ActiveSupport::TimeWithZone)),
      now: T.any(Date, Time, ActiveSupport::TimeWithZone)
    ).returns(T.nilable(Integer))
  end
  def self.in_years(dob, now = Date.current)
    return nil if dob.blank?

    # reference: http://stackoverflow.com/questions/819263/get-persons-age-in-ruby#comment21200772_819263
    now.year - dob.year - (now.month > dob.month || (now.month == dob.month && now.day >= dob.day) ? 0 : 1)
  end
end
