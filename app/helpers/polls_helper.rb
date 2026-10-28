# typed: true
module PollsHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params(booth: Poll::Booth).returns(String) }
  def booth_name_with_location(booth)
    location = booth.location.blank? ? "" : " (#{booth.location})"
    T.must(booth.name) + location
  end

  sig { returns(T::Boolean) }
  def results_menu?
    controller_name == "polls" && action_name == "results"
  end

  sig { returns(T::Boolean) }
  def stats_menu?
    controller_name == "polls" && action_name == "stats"
  end

  sig { returns(T::Boolean) }
  def info_menu?
    controller_name == "polls" && action_name == "show"
  end

  sig { returns(T::Boolean) }
  def show_polls_description?
    @active_poll.present? && @current_filter == "current"
  end
end
