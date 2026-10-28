# typed: strict
module Widget
  extend T::Sig

  sig { returns(String) }
  def self.table_name_prefix
    "widget_"
  end
end
