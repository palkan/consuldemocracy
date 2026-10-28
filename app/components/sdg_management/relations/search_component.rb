# typed: strict
class SDGManagement::Relations::SearchComponent < ApplicationComponent
  include SDG::OptionsForSelect

  sig { returns(String) }
  attr_reader :label

  sig { params(label: String).void }
  def initialize(label:)
    @label = label
  end

  private

    sig { returns(String) }
    def goal_label
      t("admin.shared.search.advanced_filters.sdg_goals.label")
    end

    sig { returns(String) }
    def goal_blank_option
      t("admin.shared.search.advanced_filters.sdg_goals.all")
    end

    sig { returns(String) }
    def target_label
      t("admin.shared.search.advanced_filters.sdg_targets.label")
    end

    sig { returns(String) }
    def target_blank_option
      t("admin.shared.search.advanced_filters.sdg_targets.all")
    end

    sig { override(allow_incompatible: true).returns(ActiveSupport::SafeBuffer) }
    def goal_options
      super(params[:goal_code])
    end

    sig { override(allow_incompatible: true).returns(ActiveSupport::SafeBuffer) }
    def target_options
      super(params[:target_code])
    end
end
