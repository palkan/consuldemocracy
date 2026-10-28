# typed: strict
class Moderation::Users::IndexComponent < ApplicationComponent
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
      t("moderation.users.index.title")
    end

    sig { params(user: User).returns(String) }
    def status(user)
      t("admin.activity.show.actions.#{activity_action(user)}")
    end

    sig { params(user: User).returns(String) }
    def activity_action(user)
      Activity.where(actionable: user, action: [:hide, :block]).last&.action || "block"
    end
end
