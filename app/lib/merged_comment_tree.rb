# typed: strict
class MergedCommentTree < CommentTree
  sig { returns(T::Array[T.any(Legislation::Annotation, Legislation::Annotation::PrivateRelation)]) }
  attr_reader :commentables

  sig do
    params(
      commentables: T::Array[T.any(Legislation::Annotation, Legislation::Annotation::PrivateRelation)],
      page: T.nilable(T.any(String, Integer)),
      order: String
    ).void
  end
  def initialize(commentables, page, order = "confidence_score")
    @commentables = commentables
    super(commentables.first, page, order)
  end

  sig { returns(Comment::PrivateRelation) }
  def base_comments
    Comment.where(commentable: commentables.flatten)
  end
end
