# typed: strict
class SDGManagement::Targets::IndexComponent < ApplicationComponent
  include Header

  sig { returns(T::Array[SDG::Target]) }
  attr_reader :targets

  sig { params(targets: T::Array[SDG::Target]).void }
  def initialize(targets)
    @targets = targets
  end

  private

    sig { override.returns(String) }
    def title
      SDG::Target.model_name.human(count: 2).titleize
    end

    sig { params(attribute: Symbol).returns(String) }
    def attribute_name(attribute)
      SDG::Target.human_attribute_name(attribute)
    end

    sig { params(object: T.any(SDG::Goal, SDG::Target)).returns(String) }
    def header_id(object)
      "#{dom_id(object)}_header"
    end
end
