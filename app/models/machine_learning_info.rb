# typed: strict
class MachineLearningInfo < ApplicationRecord
  sig { params(kind: T.any(String, Symbol)).returns(T.nilable(MachineLearningInfo)) }
  def self.for(kind)
    find_by(kind: kind)
  end
end
