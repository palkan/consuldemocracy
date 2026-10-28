# typed: strict
class Shared::CommentsCountComponent < ApplicationComponent
  sig { returns(Integer) }
  attr_reader :comments_count

  sig { returns(T.nilable(String)) }
  attr_reader :url

  sig { params(comments_count: Integer, url: T.nilable(String)).void }
  def initialize(comments_count, url: nil)
    @comments_count = comments_count
    @url = url
  end

  sig { returns(String) }
  def text
    t("shared.comments", count: comments_count)
  end
end
