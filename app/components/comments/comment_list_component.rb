# typed: strict
class Comments::CommentListComponent < ApplicationComponent
  sig { returns(T::Enumerable[Comment]) }
  attr_reader :comments

  sig { returns(T.nilable(CommentTree)) }
  attr_reader :comment_tree

  sig { returns(T::Boolean) }
  attr_reader :valuation

  sig do
    params(comments: T::Enumerable[Comment], comment_tree: T.nilable(CommentTree), valuation: T::Boolean).void
  end
  def initialize(comments, comment_tree:, valuation: false)
    @comments = comments
    @comment_tree = comment_tree
    @valuation = valuation
  end
end
