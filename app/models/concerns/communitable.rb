# typed: strict
module Communitable
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ApplicationRecord }

  included do
    belongs_to :community
    before_create :associate_community
  end

  sig { void }
  def associate_community
    community = Community.create!
    self.community_id = community.id
  end
end
