# typed: strict
module VotesHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params(debate: T.any(Debate, Legislation::Proposal)).returns(Integer) }
  def debate_percentage_of_likes(debate)
    (debate.likes.to_f * 100 / T.must(debate.total_votes)).to_i
  end

  sig { params(vote: String, debate: T.any(Debate, Legislation::Proposal)).returns(T.nilable(String)) }
  def votes_percentage(vote, debate)
    return "0%" if debate.total_votes == 0

    if vote == "likes"
      "#{debate_percentage_of_likes(debate)}%"
    elsif vote == "dislikes"
      "#{100 - debate_percentage_of_likes(debate)}%"
    end
  end
end
