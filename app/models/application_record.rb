# typed: strict
class ApplicationRecord < ActiveRecord::Base
  extend T::Sig

  include HumanName
  include SkipValidation

  self.abstract_class = true

  sig { params(count: Integer).returns(T.any(T.nilable(T.attached_class), ActiveRecord::Relation)) }
  def self.sample(count = 1)
    if count == 1
      reorder(Arel.sql("RANDOM()")).first
    else
      reorder(Arel.sql("RANDOM()")).limit(count)
    end
  end
end
