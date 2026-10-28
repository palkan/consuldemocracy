# typed: strict
class Widget::Feeds::FeedComponent < ApplicationComponent
  sig { returns(T.untyped) }
  attr_reader :feed

  delegate :kind, to: :feed

  sig { params(feed: T.untyped).void }
  def initialize(feed)
    @feed = feed
  end

  sig { returns(String) }
  def see_all_path
    polymorphic_path(feed.items.model, filters)
  end

  private

    sig do
      returns(
        T.nilable(
          T.any(
            T.class_of(Widget::Feeds::ProposalComponent),
            T.class_of(Widget::Feeds::DebateComponent),
            T.class_of(Widget::Feeds::ProcessComponent)
          )
        )
      )
    end
    def item_component_class
      case kind
      when "proposals"
        Widget::Feeds::ProposalComponent
      when "debates"
        Widget::Feeds::DebateComponent
      when "processes"
        Widget::Feeds::ProcessComponent
      end
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def filters
      if feed.respond_to?(:goal) && kind != "processes"
        { advanced_search: { goal: feed.goal.code }}
      else
        {}
      end
    end
end
