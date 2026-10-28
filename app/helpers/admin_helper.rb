# typed: strict
module AdminHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }
  requires_ancestor { SettingsHelper }

  sig { returns(String) }
  def namespaced_root_path
    "/#{namespace}"
  end

  sig { returns(T::Array[[String, Integer]]) }
  def official_level_options
    options = T.let([["", 0]], T::Array[[String, Integer]])
    (1..5).each do |i|
      options << [
        [t("admin.officials.level_#{i}"), setting["official_level_#{i}_name"]].compact.join(": "),
        i
      ]
    end
    options
  end

  sig { params(resource: ActiveRecord::Base).returns(String) }
  def admin_submit_action(resource)
    resource.persisted? ? "edit" : "new"
  end

  sig { params(user: User).returns(T::Array[Symbol]) }
  def user_roles(user)
    roles = []
    roles << :admin if user.administrator?
    roles << :moderator if user.moderator?
    roles << :valuator if user.valuator?
    roles << :manager if user.manager?
    roles << :poll_officer if user.poll_officer?
    roles << :official if user.official?
    roles << :organization if user.organization?
    roles
  end

  sig { params(user: User).returns(String) }
  def display_user_roles(user)
    user_roles(user).join(", ")
  end

  sig { returns(String) }
  def namespace
    controller.class.name.split("::").first.underscore
  end
end
