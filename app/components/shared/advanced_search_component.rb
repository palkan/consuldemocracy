# typed: strict
class Shared::AdvancedSearchComponent < ApplicationComponent
  include SDG::OptionsForSelect

  private

    sig { returns(T.untyped) }
    def advanced_search
      params[:advanced_search] || {}
    end

    sig { returns(ActiveSupport::SafeBuffer) }
    def date_range_options
      options_for_select(
        [
          [t("shared.advanced_search.date_1"), 1],
          [t("shared.advanced_search.date_2"), 2],
          [t("shared.advanced_search.date_3"), 3],
          [t("shared.advanced_search.date_4"), 4],
          [t("shared.advanced_search.date_5"), "custom"]
        ],
        selected_date_range
      )
    end

    sig { returns(T.nilable(String)) }
    def selected_date_range
      custom_date_range? ? "custom" : advanced_search[:date_min]
    end

    sig { returns(T::Boolean) }
    def custom_date_range?
      advanced_search[:date_max].present?
    end

    sig { override(allow_incompatible: true).returns(ActiveSupport::SafeBuffer) }
    def goal_options
      super(advanced_search[:goal])
    end

    sig { override(allow_incompatible: true).returns(ActiveSupport::SafeBuffer) }
    def target_options
      super(advanced_search[:target])
    end

    sig { returns(T.nilable(T::Boolean)) }
    def sdg?
      SDG::ProcessEnabled.new(controller_path).enabled?
    end
end
