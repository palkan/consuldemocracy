# typed: true
class Admin::HomepageController < Admin::BaseController
  sig { void }
  def show
    load_header
    load_feeds
    load_recommendations
    load_cards
  end

  private

    sig { void }
    def load_header
      @header = ::Widget::Card.header
    end

    sig { void }
    def load_recommendations
      @recommendations = Setting.find_by(key: "feature.user.recommendations")
    end

    sig { void }
    def load_cards
      @cards = ::Widget::Card.body
    end

    sig { void }
    def load_feeds
      @feeds = Widget::Feed.order(:created_at)
    end
end
