# typed: strict
module Graphqlable
  extend ActiveSupport::Concern
  extend T::Sig

  sig { returns(ActiveSupport::TimeWithZone) }
  def public_created_at
    T.must(created_at).change(min: 0)
  end
end
