# typed: strict
class Admin::SDG::Managers::IndexComponent < ApplicationComponent
  include Header

  sig { returns(User::PrivateRelation) }
  attr_reader :users

  sig { params(users: User::PrivateRelation).void }
  def initialize(users)
    @users = users
  end

  private

    sig { override.returns(String) }
    def title
      SDG::Manager.model_name.human(count: 2).upcase_first
    end
end
