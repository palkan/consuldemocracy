# typed: strict
class SDG::TagComponent < ApplicationComponent
  sig { returns(T.any(SDG::Goal, SDG::Target, SDG::LocalTarget)) }
  attr_reader :goal_or_target

  sig { params(goal_or_target: T.any(SDG::Goal, SDG::Target, SDG::LocalTarget)).void }
  def initialize(goal_or_target)
    @goal_or_target = goal_or_target
  end

  sig { returns(String) }
  def text
    goal = goal_or_target

    if goal.is_a?(SDG::Goal)
      render SDG::Goals::IconComponent.new(goal)
    else
      "#{SDG::Target.model_name.human} #{goal_or_target.code}"
    end
  end
end
