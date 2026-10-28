# typed: strict
class Debates::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  sig { returns(Debate) }
  attr_reader :debate

  delegate :suggest_data, to: :helpers

  sig { params(debate: Debate).void }
  def initialize(debate)
    @debate = debate
  end
end
