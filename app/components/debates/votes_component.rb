# typed: strict
class Debates::VotesComponent < ApplicationComponent
  sig { returns(Debate) }
  attr_reader :debate

  delegate :link_to_verify_account, to: :helpers

  sig { params(debate: Debate).void }
  def initialize(debate)
    @debate = debate
  end

  private

    sig { returns(T::Boolean) }
    def can_vote?
      debate.votable_by?(current_user)
    end

    sig { returns(T.nilable(String)) }
    def cannot_vote_text
      t("votes.anonymous", verify_account: link_to_verify_account) unless can_vote?
    end
end
