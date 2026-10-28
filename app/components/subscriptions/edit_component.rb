# typed: strict
class Subscriptions::EditComponent < ApplicationComponent
  sig { returns(User) }
  attr_reader :user

  sig { params(user: User).void }
  def initialize(user)
    @user = user
  end
end
