# typed: strict
class SDGManagement::Goals::IndexComponent < ApplicationComponent
  include Header

  sig { returns(SDG::Goal::PrivateRelation) }
  attr_reader :goals

  sig { params(goals: SDG::Goal::PrivateRelation).void }
  def initialize(goals)
    @goals = goals
  end

  private

    sig { override.returns(String) }
    def title
      SDG::Goal.model_name.human(count: 2).titleize
    end

    sig { params(attribute: Symbol).returns(String) }
    def attribute_name(attribute)
      SDG::Goal.human_attribute_name(attribute)
    end
end
