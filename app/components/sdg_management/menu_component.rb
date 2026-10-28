# typed: strict
class SDGManagement::MenuComponent < ApplicationComponent
  delegate :link_list, to: :helpers

  private

    sig { returns(T::Array[T.nilable(T::Array[T.untyped])]) }
    def links
      [goals_link, homepage_link, *relatable_links]
    end

    sig { returns(T::Array[T.untyped]) }
    def goals_link
      [item_text("sdg_content"), sdg_management_goals_path, sdg?, class: "goals-link"]
    end

    sig { returns(T::Array[T.untyped]) }
    def homepage_link
      [item_text("sdg_homepage"), sdg_management_homepage_path, homepage?, class: "homepage-link"]
    end

    sig { returns(T::Array[T.nilable(T::Array[T.untyped])]) }
    def relatable_links
      SDG::Related::RELATABLE_TYPES.map do |type|
        next unless SDG::ProcessEnabled.new(type).enabled?

        [
          item_text(table_name(type)),
          relatable_type_path(type),
          controller_name == "relations" && params[:relatable_type] == type.tableize,
          class: "#{table_name(type).tr("_", "-")}-link"
        ]
      end
    end

    sig { returns(T::Boolean) }
    def sdg?
      %w[goals targets local_targets].include?(controller_name)
    end

    sig { returns(T::Boolean) }
    def homepage?
      controller_name == "homepage"
    end

    sig { params(type: String).returns(T::Hash[Symbol, T.any(String, Symbol)]) }
    def relatable_type_path(type)
      {
        controller: "sdg_management/relations",
        action: :index,
        relatable_type: type.tableize
      }
    end

    sig { params(type: String).returns(String) }
    def table_name(type)
      type.constantize.table_name
    end

    sig { params(item: String).returns(String) }
    def item_text(item)
      t("sdg_management.menu.#{item}")
    end
end
