# typed: strict
module Dashboard
  extend T::Sig

  sig { returns(String) }
  def self.table_name_prefix
    "dashboard_"
  end
end
