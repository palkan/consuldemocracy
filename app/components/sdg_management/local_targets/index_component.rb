# typed: strict
class SDGManagement::LocalTargets::IndexComponent < ApplicationComponent
  include Header

  sig { returns(T::Array[SDG::LocalTarget]) }
  attr_reader :local_targets

  sig { params(local_targets: T::Array[SDG::LocalTarget]).void }
  def initialize(local_targets)
    @local_targets = local_targets
  end

  private

    sig { override.returns(String) }
    def title
      SDG::LocalTarget.model_name.human(count: 2).titleize
    end

    sig { params(attribute: Symbol).returns(String) }
    def attribute_name(attribute)
      SDG::LocalTarget.human_attribute_name(attribute)
    end

    sig { params(object: T.any(SDG::Target, SDG::LocalTarget)).returns(String) }
    def header_id(object)
      "#{dom_id(object)}_header"
    end

    sig { params(local_target: SDG::LocalTarget).returns(String) }
    def actions(local_target)
      render Admin::TableActionsComponent.new(local_target)
    end
end
