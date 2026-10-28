# typed: strict
class Shared::CommentsComponent < ApplicationComponent
  sig { returns(T.untyped) }
  attr_reader :record

  sig { returns(T::Boolean) }
  attr_reader :valuation

  delegate :current_order, :locale_and_user_status, :commentable_cache_key, to: :helpers

  sig { params(record: T.untyped, comment_tree: T.nilable(CommentTree), valuation: T::Boolean).void }
  def initialize(record, comment_tree = nil, valuation: false)
    @record = record
    @comment_tree = comment_tree
    @valuation = valuation
  end

  sig { returns(CommentTree) }
  def comment_tree
    @comment_tree ||= CommentTree.new(record, params[:page], current_order, valuations: valuation)
  end

  private

    sig { returns(T::Array[T.untyped]) }
    def cache_key
      [
        locale_and_user_status,
        current_order,
        commentable_cache_key(record),
        comment_tree.comments,
        comment_tree.comment_authors,
        record.comments_count
      ]
    end
end
