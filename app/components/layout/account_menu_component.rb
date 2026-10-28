# typed: strict
class Layout::AccountMenuComponent < ApplicationComponent
  sig { returns(T.nilable(User)) }
  attr_reader :user

  sig { params(user: T.nilable(User)).void }
  def initialize(user)
    @user = user
  end
end
