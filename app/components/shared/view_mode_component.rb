# typed: strict
class Shared::ViewModeComponent < ApplicationComponent
  delegate :default_view_mode?, :current_path_with_query_params, :link_list, to: :helpers

  private

    sig { returns(T::Array[T::Array[T.untyped]]) }
    def links
      [
        [
          t("shared.view_mode.cards"),
          default_view_mode_path,
          default_view_mode?,
          class: "view-card"
        ],
        [
          t("shared.view_mode.list"),
          minimal_view_mode_path,
          !default_view_mode?,
          class: "view-list"
        ]
      ]
    end

    sig { returns(T.nilable(String)) }
    def view_mode
      "minimal" unless default_view_mode?
    end

    sig { returns(String) }
    def default_view_mode_path
      current_path_with_query_params(view: "default")
    end

    sig { returns(String) }
    def minimal_view_mode_path
      current_path_with_query_params(view: "minimal")
    end
end
