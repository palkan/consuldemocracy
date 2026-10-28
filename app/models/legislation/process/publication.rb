# typed: strict
class Legislation::Process::Publication
  extend T::Sig

  sig { params(publication_date: T.nilable(Date), enabled: T.nilable(T::Boolean)).void }
  def initialize(publication_date, enabled)
    @publication_date = publication_date
    @enabled = enabled
  end

  sig { returns(T.nilable(T::Boolean)) }
  def enabled?
    @enabled
  end

  sig { returns(T.nilable(T::Boolean)) }
  def started?
    enabled? && Date.current >= T.must(@publication_date)
  end

  sig { returns(T.nilable(T::Boolean)) }
  def open?
    started?
  end
end
