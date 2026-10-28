# typed: strict
class Comments::InfoComponent < ApplicationComponent
  sig { returns(Comment) }
  attr_reader :comment

  sig { returns(T::Boolean) }
  attr_reader :valuation

  sig { params(comment: Comment, valuation: T::Boolean).void }
  def initialize(comment, valuation: false)
    @comment = comment
    @valuation = valuation
  end
end
