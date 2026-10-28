# typed: strict
class Admin::Poll::Shifts::FormComponent < ApplicationComponent
  sig { returns(::Poll::Shift) }
  attr_reader :shift

  sig { returns(::Poll::Booth) }
  attr_reader :booth

  sig { returns(::Poll::Officer) }
  attr_reader :officer

  sig { params(shift: ::Poll::Shift, booth: ::Poll::Booth, officer: ::Poll::Officer).void }
  def initialize(shift, booth:, officer:)
    @shift = shift
    @booth = booth
    @officer = officer
  end

  private

    sig { returns(::Poll::PrivateAssociationRelation) }
    def voting_polls
      booth.polls.current
    end

    sig { returns(T.any(::Poll::PrivateRelation, ::Poll::PrivateAssociationRelation)) }
    def recount_polls
      booth.polls.current_or_recounting
    end

    sig { returns(T::Array[[String, String]]) }
    def shift_vote_collection_dates
      return [] if voting_polls.blank?

      date_options(voting_start_date..voting_end_date, Poll::Shift.tasks[:vote_collection])
    end

    sig { returns(T::Array[[String, String]]) }
    def shift_recount_scrutiny_dates
      return [] if recount_polls.blank?

      dates = recount_polls.map { |poll| T.must(poll.ends_at).to_date }.sort.reduce([]) do |total, date|
        initial_date = [date, Date.current].max
        total << (initial_date..date + Poll::RECOUNT_DURATION).to_a
      end
      date_options(dates.flatten.uniq, Poll::Shift.tasks[:recount_scrutiny])
    end

    sig { params(dates: T::Enumerable[Date], task_id: T.untyped).returns(T::Array[[String, String]]) }
    def date_options(dates, task_id)
      valid_dates(dates, task_id).map { |date| [l(date, format: :long), l(date)] }
    end

    sig { params(dates: T::Enumerable[Date], task_id: T.untyped).returns(T::Array[Date]) }
    def valid_dates(dates, task_id)
      dates.reject { |date| officer_shifts(task_id).include?(date) }
    end

    sig { returns(Date) }
    def voting_start_date
      start_date = voting_polls.minimum(:starts_at).to_date
      [start_date, Date.current].max
    end

    sig { returns(Date) }
    def voting_end_date
      voting_polls.maximum(:ends_at).to_date
    end

    sig { params(task_id: T.untyped).returns(T::Array[T.nilable(Date)]) }
    def officer_shifts(task_id)
      officer.shifts.where(task: task_id, booth: booth).map(&:date)
    end
end
