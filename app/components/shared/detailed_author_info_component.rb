# typed: strict
class Shared::DetailedAuthorInfoComponent < ApplicationComponent
  sig { returns(User) }
  attr_reader :author

  sig { params(author: User).void }
  def initialize(author)
    @author = author
  end
end
