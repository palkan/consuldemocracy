# typed: strict
class SDG::Goals::TagCloudComponent < ApplicationComponent
  sig { returns(String) }
  attr_reader :class_name

  sig { params(class_name: String).void }
  def initialize(class_name)
    @class_name = class_name
  end

  sig { returns(T.nilable(T::Boolean)) }
  def render?
    SDG::ProcessEnabled.new(class_name).enabled?
  end

  private

    sig { returns(String) }
    def heading
      t("sdg.goals.filter.heading")
    end

    sig { returns(SDG::Goal::PrivateRelation) }
    def goals
      SDG::Goal.order(:code)
    end
end
