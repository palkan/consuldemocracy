# typed: strict
class Shared::InFavorAgainstComponent < ApplicationComponent
  sig { returns(T.any(Debate, Legislation::Proposal)) }
  attr_reader :votable

  delegate :votes_percentage, to: :helpers

  sig { params(votable: T.any(Debate, Legislation::Proposal)).void }
  def initialize(votable)
    @votable = votable
  end

  private

    sig { returns(String) }
    def agree_aria_label
      t("votes.agree_label", title: votable.title)
    end

    sig { returns(String) }
    def disagree_aria_label
      t("votes.disagree_label", title: votable.title)
    end
end
