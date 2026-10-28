# typed: strict
class Admin::Debates::IndexComponent < ApplicationComponent
  include Header

  sig { returns(Debate::PrivateRelation) }
  attr_reader :debates

  sig { params(debates: Debate::PrivateRelation).void }
  def initialize(debates)
    @debates = debates
  end

  sig { override.returns(String) }
  def title
    t("admin.debates.index.title")
  end
end
