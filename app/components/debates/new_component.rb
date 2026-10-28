# typed: strict
class Debates::NewComponent < ApplicationComponent
  include Header

  sig { returns(Debate) }
  attr_reader :debate

  delegate :new_window_link_to, to: :helpers

  sig { params(debate: Debate).void }
  def initialize(debate)
    @debate = debate
  end

  sig { override.returns(String) }
  def title
    t("debates.new.start_new")
  end
end
