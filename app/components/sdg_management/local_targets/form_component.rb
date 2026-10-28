# typed: strict
class SDGManagement::LocalTargets::FormComponent < ApplicationComponent
  include Header
  include TranslatableFormHelper
  include GlobalizeHelper

  sig { returns(SDG::LocalTarget) }
  attr_reader :local_target

  sig { params(local_target: SDG::LocalTarget).void }
  def initialize(local_target)
    @local_target = local_target
  end

  private

    sig { override.returns(String) }
    def title
      if local_target.persisted?
        t("sdg_management.local_targets.edit.title")
      else
        t("sdg_management.local_targets.new.title")
      end
    end

    sig { returns(String) }
    def form_url
      if local_target.persisted?
        sdg_management_local_target_path(local_target)
      else
        sdg_management_local_targets_path
      end
    end

    sig { returns(ActiveSupport::SafeBuffer) }
    def target_options
      grouped_targets = SDG::Goal.order(:code).map do |goal|
        [
          goal.code_and_title,
          goal.targets.sort.map { |target| [target.code_and_title, target.id] }
        ]
      end
      grouped_options_for_select(grouped_targets, local_target.target_id)
    end
end
