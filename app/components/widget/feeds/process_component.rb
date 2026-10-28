# typed: strict
class Widget::Feeds::ProcessComponent < ApplicationComponent
  delegate :image_path_for, to: :helpers

  sig { returns(Legislation::Process) }
  attr_reader :process

  sig { params(process: Legislation::Process).void }
  def initialize(process)
    @process = process
  end
end
