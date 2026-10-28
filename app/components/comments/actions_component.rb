# typed: strict
class Comments::ActionsComponent < ApplicationComponent
  sig { returns(Comment) }
  attr_reader :comment

  sig { params(comment: Comment).void }
  def initialize(comment)
    @comment = comment
  end
end
