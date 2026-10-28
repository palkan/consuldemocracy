# typed: strict
class Lock < ApplicationRecord
  belongs_to :user

  before_save :set_locked_until

  sig { returns(T::Boolean) }
  def locked?
    locked_until > Time.current
  end

  sig { void }
  def set_locked_until
    self.locked_until = lock_time if too_many_tries?
  end

  sig { returns(ActiveSupport::TimeWithZone) }
  def lock_time
    Time.current + (2**T.must(tries)).minutes
  end

  sig { returns(T::Boolean) }
  def too_many_tries?
    current_tries = T.must(tries)
    current_tries > 0 && current_tries % Lock.max_tries == 0
  end

  sig { params(user: T.nilable(User)).returns(T::Boolean) }
  def self.increase_tries(user)
    find_or_create_by!(user: user).increment!(:tries).save!
  end

  sig { returns(Integer) }
  def self.max_tries
    5
  end
end
