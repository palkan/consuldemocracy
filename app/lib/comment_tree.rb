# typed: strict
class CommentTree
  extend T::Sig

  ROOT_COMMENTS_PER_PAGE = 10

  # Any model with comments (Debate, Proposal, Budget::Investment, Legislation::Question...)
  sig { returns(T.untyped) }
  attr_reader :commentable

  sig { returns(T.nilable(T.any(String, Integer))) }
  attr_reader :page

  sig { returns(String) }
  attr_reader :order

  sig do
    params(
      commentable: T.untyped,
      page: T.nilable(T.any(String, Integer)),
      order: String,
      valuations: T::Boolean
    ).void
  end
  def initialize(commentable, page, order = "confidence_score", valuations: false)
    @commentable = commentable
    @page = page
    @order = order
    @valuations = valuations
    @comments = T.let(nil, T.nilable(T::Array[Comment]))
  end

  sig { returns(T::Array[Comment]) }
  def comments
    @comments ||= root_comments + root_descendants
  end

  sig { returns(T.any(Comment::PrivateRelation, Comment::PrivateAssociationRelation)) }
  def root_comments
    base_comments.roots.send("sort_by_#{order}").page(page).per(ROOT_COMMENTS_PER_PAGE).for_render
  end

  sig do
    returns(
      T.any(Comment::PrivateRelation, Comment::PrivateAssociationRelation, Comment::PrivateCollectionProxy)
    )
  end
  def base_comments
    if @valuations && commentable.respond_to?(:valuations)
      commentable.valuations
    else
      commentable.comments
    end
  end

  sig { returns(T::Array[Comment]) }
  def root_descendants
    root_comments.each_with_object([]) do |root, array|
      array.concat(Comment.descendants_of(root).send("sort_descendants_by_#{order}").for_render.to_a)
    end
  end

  sig { params(parent: Comment).returns(T::Array[Comment]) }
  def ordered_children_of(parent)
    comments_by_parent_id[parent.id] || []
  end

  sig { returns(T::Hash[T.nilable(Integer), T::Array[Comment]]) }
  def comments_by_parent_id
    comments.each_with_object({}) do |comment, array|
      (array[comment.parent_id] ||= []) << comment
    end
  end

  sig { returns(T::Array[T.nilable(User)]) }
  def comment_authors
    comments.map(&:author)
  end
end
