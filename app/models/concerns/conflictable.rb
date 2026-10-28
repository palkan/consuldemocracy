# typed: strict
module Conflictable
  extend ActiveSupport::Concern
  extend T::Sig

  sig { returns(T::Boolean) }
  def conflictive?
    flags = T.must(flags_count)
    flags > 0 && T.must(cached_votes_up) / flags.to_f < 5
  end
end
