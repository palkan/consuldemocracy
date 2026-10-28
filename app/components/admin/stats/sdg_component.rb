# typed: strict
class Admin::Stats::SDGComponent < ApplicationComponent
  include Header

  sig { returns(SDG::Goal::PrivateRelation) }
  attr_reader :goals

  sig { params(goals: SDG::Goal::PrivateRelation).void }
  def initialize(goals)
    @goals = goals
  end

  private

    sig { override.returns(String) }
    def title
      t("admin.stats.sdg.title")
    end
end
