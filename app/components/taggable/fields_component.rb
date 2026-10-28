# typed: strict
class Taggable::FieldsComponent < ApplicationComponent
  sig { returns(ActionView::Helpers::FormBuilder) }
  attr_reader :form

  sig { returns(String) }
  attr_reader :i18n_namespace

  sig { returns(T::Boolean) }
  attr_reader :autocomplete

  sig do
    params(
      form: ActionView::Helpers::FormBuilder,
      i18n_namespace: String,
      categories: T.nilable(T::Enumerable[T.untyped]),
      autocomplete: T::Boolean
    ).void
  end
  def initialize(form, i18n_namespace:, categories: nil, autocomplete: true)
    @form = form
    @i18n_namespace = i18n_namespace
    @categories = categories
    @autocomplete = autocomplete
  end

  sig { returns(T::Enumerable[T.untyped]) }
  def categories
    @categories ||= Tag.category.order(:name)
  end

  private

    sig { params(category: T.untyped).returns(String) }
    def category_name(category)
      category.respond_to?(:name) ? category.name : category.to_s
    end

    sig { returns(String) }
    def tag_list_classes
      classes = ["js-tag-list"]
      classes << "tag-autocomplete" if autocomplete
      classes.join(" ")
    end

    sig { returns(T::Hash[Symbol, String]) }
    def tag_list_data
      autocomplete ? { js_url: suggest_tags_path } : {}
    end

    sig { returns(String) }
    def tags_label
      t("#{i18n_namespace}.tags_label")
    end

    sig { returns(String) }
    def tags_instructions
      t("#{i18n_namespace}.tags_instructions")
    end

    sig { returns(String) }
    def tags_placeholder
      t("#{i18n_namespace}.tags_placeholder")
    end

    sig { returns(String) }
    def tag_category_label
      t("#{i18n_namespace}.tag_category_label")
    end
end
