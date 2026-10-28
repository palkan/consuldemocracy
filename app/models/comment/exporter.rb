# typed: strict
class Comment::Exporter
  include JsonExporter
  extend T::Sig

  sig { returns(T.class_of(Comment)) }
  def model
    Comment
  end

  private

    sig { params(comment: Comment).returns(T::Hash[Symbol, T.untyped]) }
    def json_values(comment)
      {
        id: comment.id,
        commentable_id: comment.commentable_id,
        commentable_type: comment.commentable_type,
        body: strip_tags(comment.body)
      }
    end
end
