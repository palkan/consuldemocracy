# typed: strict
class Budgets::Investments::FiltersComponent < ApplicationComponent
  delegate :valid_filters, :current_filter, :link_list, :current_path_with_query_params, to: :helpers

  sig { returns(T.nilable(T::Boolean)) }
  def render?
    valid_filters&.any?
  end

  private

    sig { returns(T::Array[T::Array[T.untyped]]) }
    def filters
      valid_filters.map do |filter|
        [
          t("budgets.investments.index.filters.#{filter}"),
          current_path_with_query_params(filter: filter, page: 1),
          current_filter == filter
        ]
      end
    end
end
