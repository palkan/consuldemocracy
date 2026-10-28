# typed: strict
class SDG::Goals::TargetsComponent < ApplicationComponent
  Targets = T.type_alias do
    T.any(SDG::Target::PrivateCollectionProxy, SDG::LocalTarget::PrivateCollectionProxy)
  end

  sig { returns(SDG::Goal) }
  attr_reader :goal

  sig { params(goal: SDG::Goal).void }
  def initialize(goal)
    @goal = goal
  end

  sig { returns(T.nilable(String)) }
  def render?
    feature?("sdg")
  end

  private

    sig { returns(SDG::Target::PrivateCollectionProxy) }
    def global_targets
      goal.targets
    end

    sig { returns(SDG::LocalTarget::PrivateCollectionProxy) }
    def local_targets
      goal.local_targets
    end

    sig { params(targets: Targets).returns(String) }
    def type(targets)
      if targets.model.name == "SDG::Target"
        "global"
      else
        "local"
      end
    end

    sig { params(targets: Targets).returns(T.nilable(String)) }
    def active(targets)
      "is-active" if targets.model.name == "SDG::Target"
    end

    sig { params(targets: Targets).returns(String) }
    def title(targets)
      targets.model.model_name.human(count: :other).upcase_first
    end
end
