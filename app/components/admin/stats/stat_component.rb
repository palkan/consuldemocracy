# typed: strict
class Admin::Stats::StatComponent < ApplicationComponent
  sig { returns(String) }
  attr_reader :text

  sig { returns(T.untyped) }
  attr_reader :amount

  sig { returns(T::Hash[Symbol, T.untyped]) }
  attr_reader :options

  sig { params(text: String, amount: T.untyped, options: T::Hash[Symbol, T.untyped]).void }
  def initialize(text:, amount:, options: {})
    @text = text
    @amount = amount
    @options = options
  end
end
