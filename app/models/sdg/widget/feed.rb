# typed: strict
class SDG::Widget::Feed
  extend T::Sig

  sig { returns(::Widget::Feed) }
  attr_reader :feed

  sig { returns(SDG::Goal) }
  attr_reader :goal

  delegate :kind, to: :feed

  sig { params(feed: ::Widget::Feed, goal: SDG::Goal).void }
  def initialize(feed, goal)
    @feed = feed
    @goal = goal
  end

  sig do
    returns(T.any(Proposal::PrivateRelation, Debate::PrivateRelation, Legislation::Process::PrivateRelation))
  end
  def items
    feed.items.by_goal(goal.code)
  end

  sig { params(goal: SDG::Goal).returns(T::Array[SDG::Widget::Feed]) }
  def self.for_goal(goal)
    ::Widget::Feed.active.map { |feed| new(feed, goal) }
  end
end
