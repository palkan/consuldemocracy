# typed: strict
class Widget::Feeds::DebateComponent < ApplicationComponent
  sig { returns(Debate) }
  attr_reader :debate

  sig { params(debate: Debate).void }
  def initialize(debate)
    @debate = debate
  end
end
