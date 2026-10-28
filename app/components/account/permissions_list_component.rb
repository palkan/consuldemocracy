# typed: strict
class Account::PermissionsListComponent < ApplicationComponent
  sig { returns(User) }
  attr_reader :user

  sig { params(user: User).void }
  def initialize(user)
    @user = user
  end

  private

    sig { returns(T::Hash[String, T::Boolean]) }
    def permissions
      {
        t("verification.user_permission_debates") => true,
        t("verification.user_permission_proposal") => true,
        t("verification.user_permission_support_proposal") => user.level_two_or_three_verified?,
        t("verification.user_permission_votes") => user.level_three_verified?
      }
    end

    sig { params(allowed: T::Boolean).returns(String) }
    def allowed_class(allowed)
      if allowed
        "permission-allowed"
      else
        "permission-denied"
      end
    end
end
