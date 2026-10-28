# typed: strict
module Legislation
  extend T::Sig

  sig { returns(String) }
  def self.table_name_prefix
    "legislation_"
  end
end
