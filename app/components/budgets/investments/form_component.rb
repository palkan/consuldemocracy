# typed: strict
class Budgets::Investments::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  sig { returns(Budget::Investment) }
  attr_reader :investment

  sig { returns(String) }
  attr_reader :url

  delegate :budget_heading_select_options, :suggest_data, to: :helpers

  sig { params(investment: Budget::Investment, url: String).void }
  def initialize(investment, url:)
    @investment = investment
    @url = url
  end

  private

    sig { returns(T.nilable(Budget)) }
    def budget
      investment.budget
    end

    sig { returns(MapLocation) }
    def map_location
      investment.map_location || MapLocation.new(investment: Budget::Investment.new)
    end
end
