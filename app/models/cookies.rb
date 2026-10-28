# typed: strict
module Cookies
  extend T::Sig

  sig { returns(String) }
  def self.table_name_prefix
    "cookies_"
  end
end
