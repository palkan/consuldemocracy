# typed: strict
class Flag < ApplicationRecord
  belongs_to :user
  belongs_to :flaggable, polymorphic: true, counter_cache: true, touch: true

  scope(:by_user_and_flaggable, lambda do |user, flaggable|
    where(user_id: user.id,
          flaggable_type: flaggable.class.to_s,
          flaggable_id: flaggable.id)
  end)

  sig { params(user: T.nilable(User), flaggable: ApplicationRecord).returns(T.any(Flag, FalseClass)) }
  def self.flag(user, flaggable)
    return false if flagged?(user, flaggable)

    create!(user: user, flaggable: flaggable)
  end

  sig do
    params(user: T.nilable(User), flaggable: ApplicationRecord)
      .returns(T.any(T::Array[Flag], FalseClass))
  end
  def self.unflag(user, flaggable)
    flags = by_user_and_flaggable(user, flaggable)
    return false if flags.empty?

    flags.destroy_all
  end

  sig { params(user: T.nilable(User), flaggable: ApplicationRecord).returns(T::Boolean) }
  def self.flagged?(user, flaggable)
    return false unless user

    !!by_user_and_flaggable(user, flaggable).first
  end
end
