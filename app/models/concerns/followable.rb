# typed: strict
module Followable
  extend ActiveSupport::Concern
  extend T::Sig

  included do
    has_many :follows, as: :followable, inverse_of: :followable, dependent: :destroy
    has_many :followers, through: :follows, source: :user

    scope :followed_by_user, ->(user) {
      joins(:follows).where(follows: { user_id: user.id })
    }
  end

  sig { params(user: T.nilable(User)).returns(T::Boolean) }
  def followed_by?(user)
    followers.include?(user)
  end
end
