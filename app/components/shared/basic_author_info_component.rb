# typed: strict
class Shared::BasicAuthorInfoComponent < ApplicationComponent
  sig { returns(User) }
  attr_reader :author

  sig { returns(T::Boolean) }
  attr_reader :show_organization

  alias_method :show_organization?, :show_organization

  sig { params(author: User, show_organization: T::Boolean).void }
  def initialize(author, show_organization: true)
    @author = author
    @show_organization = show_organization
  end
end
