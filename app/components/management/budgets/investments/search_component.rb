# typed: strict
class Management::Budgets::Investments::SearchComponent < ApplicationComponent
  sig { returns(Budget) }
  attr_reader :budget

  sig { returns(String) }
  attr_reader :url

  delegate :budget_heading_select_options, to: :helpers

  sig { params(budget: Budget, url: String).void }
  def initialize(budget, url:)
    @budget = budget
    @url = url
  end

  private

    sig { returns(T::Hash[Symbol, T.any(Symbol, String)]) }
    def options
      {
        method: :get,
        class: "management-investments-search"
      }
    end

    sig { returns(String) }
    def search_label_text
      t("management.budget_investments.search.label")
    end

    sig { params(attribute: Symbol).returns(String) }
    def attribute_name(attribute)
      Budget::Investment.human_attribute_name(attribute)
    end
end
