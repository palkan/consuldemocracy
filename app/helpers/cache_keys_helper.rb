# typed: true
module CacheKeysHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params(authorable: T.untyped).returns(String) }
  def locale_and_user_status(authorable = nil)
    @cache_key_user ||= calculate_user_status(authorable)
    "#{I18n.locale}/#{@cache_key_user}"
  end

  sig { params(authorable: T.untyped).returns(String) }
  def calculate_user_status(authorable = nil)
    user_status = "user"

    if user_signed_in?
      user = T.must(current_user)
      user_status += ":signed"
      user_status += ":verified" if user.level_two_or_three_verified?
      user_status += ":org" if user.organization?
      user_status += ":admin" if user.administrator?
      user_status += ":moderator" if user.moderator?
      user_status += ":author" if authorable && authorable.author == current_user
    else
      user_status += ":visitor"
    end

    user_status
  end

  # when commentable id and type are used but no need to update cache on updated_at changes
  sig { params(commentable: T.untyped).returns(String) }
  def commentable_cache_key(commentable)
    "#{commentable.class.name}-#{commentable.id}"
  end
end
