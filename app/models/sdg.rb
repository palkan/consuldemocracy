# typed: strict
module SDG
  extend T::Sig

  sig { returns(String) }
  def self.table_name_prefix
    "sdg_"
  end
end
