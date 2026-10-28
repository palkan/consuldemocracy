# typed: strict
class Management::Account::EditPasswordManuallyComponent < ApplicationComponent
  sig { returns(User) }
  attr_reader :user

  sig { params(user: User).void }
  def initialize(user)
    @user = user
  end
end
