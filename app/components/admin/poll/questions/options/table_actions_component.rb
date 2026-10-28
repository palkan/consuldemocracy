# typed: strict
class Admin::Poll::Questions::Options::TableActionsComponent < ApplicationComponent
  sig { returns(::Poll::Question::Option) }
  attr_reader :option

  sig { params(option: ::Poll::Question::Option).void }
  def initialize(option)
    @option = option
  end
end
