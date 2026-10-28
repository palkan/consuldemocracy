# typed: strict
class SDG::Goals::IndexComponent < ApplicationComponent
  sig { returns(SDG::Goal::PrivateRelation) }
  attr_reader :goals

  sig { returns(T.nilable(Widget::Card)) }
  attr_reader :header

  sig { returns(SDG::Phase::PrivateRelation) }
  attr_reader :phases

  delegate :link_list, to: :helpers

  sig do
    params(
      goals: SDG::Goal::PrivateRelation,
      header: T.nilable(Widget::Card),
      phases: SDG::Phase::PrivateRelation
    ).void
  end
  def initialize(goals, header:, phases:)
    @goals = goals
    @header = header
    @phases = phases
  end

  private

    sig { returns(String) }
    def title
      t("sdg.goals.title")
    end

    sig { returns(T::Array[T::Array[String]]) }
    def goal_links
      goals.map { |goal| goal_link(goal) }
    end

    sig { params(goal: SDG::Goal).returns(T::Array[String]) }
    def goal_link(goal)
      [icon(goal), sdg_goal_path(goal.code)]
    end

    sig { params(goal: SDG::Goal).returns(String) }
    def icon(goal)
      render SDG::Goals::IconComponent.new(goal)
    end
end
