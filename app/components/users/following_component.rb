# typed: strict
class Users::FollowingComponent < ApplicationComponent
  sig { returns(User) }
  attr_reader :user

  sig { returns(T::Hash[String, T::Array[Follow]]) }
  attr_reader :follows

  sig { params(user: User, follows: T::Hash[String, T::Array[Follow]]).void }
  def initialize(user, follows:)
    @user = user
    @follows = follows
  end

  private

    sig { params(followable_type: String).returns(String) }
    def followable_type_title(followable_type)
      t("activerecord.models.#{followable_type.underscore}.other")
    end

    sig { params(followable: String).returns(T.nilable(Symbol)) }
    def followable_icon(followable)
      { proposals: "Proposal", budget: "Budget::Investment" }.invert[followable]
    end

    sig { params(follow: Follow).returns(T.nilable(String)) }
    def render_follow(follow)
      return if follow.followable.blank?

      followable = follow.followable
      partial = "#{followable_class_name(followable)}_follow"
      locals = { followable_class_name(followable).to_sym => followable }

      render partial, locals
    end

    sig { params(followable: T.untyped).returns(String) }
    def followable_class_name(followable)
      followable.class.to_s.parameterize(separator: "_")
    end
end
