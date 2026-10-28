# typed: strict
module SiteCustomization
  extend T::Sig

  sig { returns(String) }
  def self.table_name_prefix
    "site_customization_"
  end
end
