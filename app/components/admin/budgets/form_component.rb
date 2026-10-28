# typed: strict
class Admin::Budgets::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper
  include Admin::Namespace

  sig { returns(Budget) }
  attr_reader :budget

  sig { returns(T::Boolean) }
  attr_reader :wizard

  alias_method :wizard?, :wizard

  sig { params(budget: T.untyped, wizard: T::Boolean).void }
  def initialize(budget, wizard: false)
    @budget = budget
    @wizard = wizard
    @admins = T.let(nil, T.nilable(Administrator::PrivateRelation))
    @valuators = T.let(nil, T.nilable(Valuator::PrivateRelation))
  end

  sig { returns(T::Array[[String, String]]) }
  def voting_styles_select_options
    Budget::VOTING_STYLES.map do |style|
      [Budget.human_attribute_name("voting_style_#{style}"), style]
    end
  end

  sig { returns(T::Array[[String, String]]) }
  def currency_symbol_select_options
    Budget::CURRENCY_SYMBOLS.map { |cs| [cs, cs] }
  end

  sig { returns(T::Array[[String, String]]) }
  def phases_select_options
    Budget::Phase::PHASE_KINDS.map { |ph| [t("budgets.phase.#{ph}"), ph] }
  end

  private

    sig { returns(Administrator::PrivateRelation) }
    def admins
      @admins ||= Administrator.includes(:user)
    end

    sig { returns(Valuator::PrivateRelation) }
    def valuators
      @valuators ||= Valuator.includes(:user).order(description: :asc).order("users.email ASC")
    end

    sig { returns(T.nilable(String)) }
    def hide_money_style
      "hide" if budget.voting_style == "knapsack"
    end
end
