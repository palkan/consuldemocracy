# typed: strict
module FollowablesHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params(user: T.nilable(User), followable: T.untyped).returns(Follow) }
  def find_or_build_follow(user, followable)
    Follow.find_or_initialize_by(user: user, followable: followable)
  end
end
