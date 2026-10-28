# typed: strict
class Polls::PollComponent < ApplicationComponent
  sig { returns(Poll) }
  attr_reader :poll

  sig { params(poll: Poll).void }
  def initialize(poll)
    @poll = poll
  end

  private

    sig { returns(String) }
    def dates
      t("polls.dates", open_at: l(T.must(poll.starts_at).to_date), closed_at: l(T.must(poll.ends_at).to_date))
    end

    sig { returns(T::Array[Poll::Question]) }
    def questions_to_list
      poll.questions.sort_for_list.first(2)
    end

    sig { returns(String) }
    def questions_count_text
      t("polls.questions_count", count: poll.questions.count)
    end

    sig { returns(T.nilable(String)) }
    def header_text
      if poll.questions.one?
        T.must(poll.questions.first).title
      else
        poll.name
      end
    end

    sig { returns(String) }
    def link_text
      if poll.expired?
        t("polls.index.participate_button_expired")
      else
        t("polls.index.participate_button")
      end
    end

    sig { returns(String) }
    def path
      if can?(:results, poll)
        results_poll_path(id: poll.slug || poll.id)
      elsif can?(:stats, poll)
        stats_poll_path(id: poll.slug || poll.id)
      else
        poll_path(id: poll.slug || poll.id)
      end
    end
end
