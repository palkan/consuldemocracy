# typed: strict
module FeedsHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params(feed: Widget::Feed).returns(T::Boolean) }
  def feed_processes?(feed)
    feed.kind == "processes"
  end

  sig { returns(T::Boolean) }
  def feed_processes_enabled?
    Setting["homepage.widgets.feeds.processes"].present?
  end
end
