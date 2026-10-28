# typed: strict
class Valuation::BudgetInvestments::DossierComponent < ApplicationComponent
  sig { returns(Budget::Investment) }
  attr_reader :investment

  delegate :sanitize_and_auto_link, to: :helpers

  sig { params(investment: Budget::Investment).void }
  def initialize(investment)
    @investment = investment
  end

  private

    sig { returns(T.nilable(Budget)) }
    def budget
      investment.budget
    end

    sig { params(field: T.nilable(String)).returns(T.nilable(ActiveSupport::SafeBuffer)) }
    def explanation_field(field)
      simple_format_no_tags_no_sanitize(sanitize_and_auto_link(field)) if field.present?
    end

    sig { params(html: String).returns(ActiveSupport::SafeBuffer) }
    def simple_format_no_tags_no_sanitize(html)
      simple_format(html, {}, sanitize: false)
    end
end
