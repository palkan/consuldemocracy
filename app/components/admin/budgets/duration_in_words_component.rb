# typed: strict
class Admin::Budgets::DurationInWordsComponent < ApplicationComponent
  sig { returns(T.untyped) }
  attr_reader :durable

  sig { params(durable: T.untyped).void }
  def initialize(durable)
    @durable = durable
  end

  sig { returns(T.untyped) }
  def render?
    durable.starts_at && durable.ends_at
  end

  private

    sig { returns(String) }
    def duration
      distance_of_time_in_words(durable.starts_at, durable.ends_at)
    end
end
