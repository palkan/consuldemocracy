# typed: strict
class SDG::Goals::HelpPageComponent < ApplicationComponent
  sig { returns(SDG::Goal::PrivateRelation) }
  attr_reader :goals

  sig { params(goals: SDG::Goal::PrivateRelation).void }
  def initialize(goals)
    @goals = goals
  end

  sig { returns(T.nilable(String)) }
  def render?
    feature?("sdg")
  end

  private

    sig { params(goal: SDG::Goal).returns(T.nilable(String)) }
    def active_class(goal)
      "is-active" if goal.code == 1
    end
end
