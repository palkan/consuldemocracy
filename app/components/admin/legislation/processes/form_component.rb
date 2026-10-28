# typed: strict
class Admin::Legislation::Processes::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  sig { returns(Legislation::Process) }
  attr_reader :process

  delegate :admin_submit_action, to: :helpers

  sig { params(process: Legislation::Process).void }
  def initialize(process)
    @process = process
  end
end
