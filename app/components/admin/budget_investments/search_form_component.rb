# typed: strict
class Admin::BudgetInvestments::SearchFormComponent < ApplicationComponent
  sig { returns(Budget) }
  attr_reader :budget

  delegate :budget_heading_select_options, to: :helpers

  sig { params(budget: Budget).void }
  def initialize(budget)
    @budget = budget
  end

  private

    sig { params(attribute: Symbol).returns(String) }
    def attribute_name(attribute)
      Budget::Investment.human_attribute_name(attribute)
    end

    sig { returns(T.untyped) }
    def advanced_filters_params
      params[:advanced_filters] ||= []
    end

    sig { returns(String) }
    def advanced_menu_visibility
      if advanced_filters_params.empty? &&
         params["min_total_supports"].blank? &&
         params["max_total_supports"].blank?
        "hide"
      else
        ""
      end
    end

    sig { returns(T::Array[[T.untyped, Integer]]) }
    def admin_select_options
      budget.administrators.with_user.map { |v| [v.description_or_name, v.id] }.sort_by { |a| T.unsafe(a[0]) }
    end

    sig { returns(T::Array[[T.untyped, String]]) }
    def valuator_or_group_select_options
      valuator_group_select_options + valuator_select_options
    end

    sig { returns(T::Array[[T.untyped, String]]) }
    def valuator_group_select_options
      ValuatorGroup.order(:name).map { |g| [g.name, "group_#{g.id}"] }
    end

    sig { returns(T::Array[[T.untyped, String]]) }
    def valuator_select_options
      budget.valuators.order(:description).order("users.email ASC").includes(:user)
            .map { |v| [v.description_or_email, "valuator_#{v.id}"] }
    end

    sig { params(context: String).returns(T::Array[String]) }
    def investment_tags_select_options(context)
      budget.investments.tags_on(context).order(:name).pluck(:name)
    end
end
