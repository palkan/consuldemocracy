# typed: strict
class Admin::Settings::TextFormComponent < ApplicationComponent
  sig { override(allow_incompatible: true).returns(Setting) }
  attr_reader :setting

  sig { returns(T.nilable(String)) }
  attr_reader :tab

  delegate :dom_id, to: :helpers

  sig { params(setting: Setting, tab: T.nilable(String)).void }
  def initialize(setting, tab: nil)
    @setting = setting
    @tab = tab
  end
end
