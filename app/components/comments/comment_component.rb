# typed: strict
class Comments::CommentComponent < ApplicationComponent
  sig { returns(Comment) }
  attr_reader :comment

  sig { returns(T.nilable(CommentTree)) }
  attr_reader :comment_tree

  sig { returns(T::Boolean) }
  attr_reader :valuation

  delegate :locale_and_user_status, :commentable_cache_key, :sanitize_and_auto_link,
           to: :helpers

  sig { params(comment: Comment, comment_tree: T.nilable(CommentTree), valuation: T::Boolean).void }
  def initialize(comment, comment_tree: nil, valuation: false)
    @comment = comment
    @comment_tree = comment_tree
    @valuation = valuation
  end

  private

    sig { returns(T::Enumerable[Comment]) }
    def child_comments
      if comment_tree.present?
        T.must(comment_tree).ordered_children_of(comment)
      else
        comment.children
      end
    end

    sig { returns(String) }
    def user_level_class
      user = T.must(comment.user)

      if comment.as_administrator?
        "is-admin"
      elsif comment.as_moderator?
        "is-moderator"
      elsif user.official?
        "level-#{user.official_level}"
      else
        ""
      end
    end

    sig { returns(String) }
    def comment_author_class
      if comment.user_id == comment.commentable.author_id
        "is-author"
      else
        ""
      end
    end
end
