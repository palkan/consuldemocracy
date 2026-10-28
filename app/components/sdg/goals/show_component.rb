# typed: strict
class SDG::Goals::ShowComponent < ApplicationComponent
  sig { returns(SDG::Goal) }
  attr_reader :goal

  delegate :code, to: :goal

  sig { params(goal: SDG::Goal).void }
  def initialize(goal)
    @goal = goal
  end

  sig { returns(T::Array[SDG::Widget::Feed]) }
  def feeds
    SDG::Widget::Feed.for_goal(goal)
  end

  private

    sig { returns(T.nilable(SDG::Widget::Feed)) }
    def processes_feed
      feeds.find { |feed| feed.kind == "processes" }
    end

    sig { returns(ActiveSupport::SafeBuffer) }
    def heading
      safe_join([tag.span(code, class: "goal-code"), tag.span(split_title, class: "goal-title")], " ")
    end

    sig { returns(T.nilable(ActiveSupport::SafeBuffer)) }
    def long_description
      sanitize t("sdg.goals.goal_#{code}.long_description")
    end

    sig { returns(ActiveSupport::SafeBuffer) }
    def split_title
      safe_join(goal.title_in_two_lines.split("\n").map { |text| tag.span(text) }, " ")
    end
end
