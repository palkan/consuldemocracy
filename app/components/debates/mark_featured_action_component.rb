# typed: strict
class Debates::MarkFeaturedActionComponent < ApplicationComponent
  sig { returns(Debate) }
  attr_reader :debate

  sig { params(debate: Debate).void }
  def initialize(debate)
    @debate = debate
  end

  sig { returns(T::Boolean) }
  def render?
    can? :mark_featured, debate
  end
end
