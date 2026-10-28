# typed: strict
class Budgets::Investments::InvestmentDetailComponent < ApplicationComponent
  sig { returns(Budget::Investment) }
  attr_reader :investment

  sig { returns(T::Boolean) }
  attr_reader :preview

  alias_method :preview?, :preview
  delegate :auto_link_already_sanitized_html, :map_location_available?,
           :render_image, :render_map, :wysiwyg, to: :helpers

  sig { params(investment: Budget::Investment, preview: T::Boolean).void }
  def initialize(investment, preview: false)
    @investment = investment
    @preview = preview
  end
end
