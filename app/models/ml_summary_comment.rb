# typed: strict
class MlSummaryComment < ApplicationRecord
  belongs_to :commentable, -> { T.bind(self, T.untyped).with_hidden }, polymorphic: true, touch: true
end
