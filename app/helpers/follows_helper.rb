# typed: strict
module FollowsHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params(followable: ActiveRecord::Base).returns(String) }
  def follow_text(followable)
    entity = T.must(followable.class.name).underscore
    t("shared.follow_entity", entity: t("activerecord.models.#{entity}.one").downcase)
  end

  sig { params(followable: ActiveRecord::Base).returns(String) }
  def unfollow_text(followable)
    entity = T.must(followable.class.name).underscore
    t("shared.unfollow_entity", entity: t("activerecord.models.#{entity}.one").downcase)
  end
end
