# typed: strict
module DebatesHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { returns(T::Boolean) }
  def has_featured?
    Debate.all.featured.any?
  end

  sig { params(user: User).returns(String) }
  def empty_recommended_debates_message_text(user)
    if user.interests.any?
      t("debates.index.recommendations.without_results")
    else
      t("debates.index.recommendations.without_interests")
    end
  end
end
