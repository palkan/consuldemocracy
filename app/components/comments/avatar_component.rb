# typed: strict
class Comments::AvatarComponent < ApplicationComponent
  sig { returns(Comment) }
  attr_reader :comment

  sig { params(comment: Comment).void }
  def initialize(comment)
    @comment = comment
  end

  private

    sig { returns(String) }
    def avatar
      user = T.must(comment.user)

      if comment.as_administrator?
        special_avatar("avatar_admin.png", class: "admin-avatar")
      elsif comment.as_moderator?
        special_avatar("avatar_moderator.png", class: "moderator-avatar")
      elsif user.hidden? || user.erased?
        tag.span(class: "icon-deleted user-deleted")
      elsif user.organization?
        special_avatar("avatar_collective.png", class: "avatar")
      else
        render Shared::AvatarComponent.new(user, size: 32)
      end
    end

    sig { params(image_name: String, options: T::Hash[Symbol, T.untyped]).returns(ActiveSupport::SafeBuffer) }
    def special_avatar(image_name, options = {})
      image_tag(image_name, { size: 32, alt: "" }.merge(options))
    end
end
