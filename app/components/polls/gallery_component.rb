# typed: strict
class Polls::GalleryComponent < ApplicationComponent
  sig { returns(Poll::Question::Option) }
  attr_reader :option

  delegate :is_active_class, to: :helpers

  sig { params(option: Poll::Question::Option).void }
  def initialize(option)
    @option = option
  end

  sig { returns(T::Boolean) }
  def render?
    option.images.any?
  end
end
