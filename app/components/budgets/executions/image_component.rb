# typed: strict
class Budgets::Executions::ImageComponent < ApplicationComponent
  sig { returns(Budget::Investment) }
  attr_reader :investment

  delegate :image_path_for, to: :helpers

  sig { params(investment: Budget::Investment).void }
  def initialize(investment)
    @investment = investment
  end

  private

    sig { returns(T.nilable(Milestone)) }
    def milestone
      investment.milestones.where.associated(:image).order_by_publication_date.last
    end

    sig { returns(T.nilable(Image)) }
    def image
      milestone&.image || investment.image
    end
end
