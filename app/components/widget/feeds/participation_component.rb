# typed: strict
class Widget::Feeds::ParticipationComponent < ApplicationComponent
  sig { returns(T::Array[T.any(Widget::Feed, SDG::Widget::Feed)]) }
  attr_reader :feeds

  sig { params(feeds: T::Array[T.any(Widget::Feed, SDG::Widget::Feed)]).void }
  def initialize(feeds)
    @feeds = feeds
  end

  private

    sig { params(feed: T.any(Widget::Feed, SDG::Widget::Feed)).returns(T::Boolean) }
    def feed_debates?(feed)
      feed.kind == "debates"
    end

    sig { params(feed: T.any(Widget::Feed, SDG::Widget::Feed)).returns(T::Boolean) }
    def feed_proposals?(feed)
      feed.kind == "proposals"
    end
end
