# typed: strict
class Layout::AdminHeaderComponent < ApplicationComponent
  sig { returns(T.nilable(User)) }
  attr_reader :user

  delegate :namespace, :namespaced_root_path, :show_admin_menu?, to: :helpers

  sig { params(user: T.nilable(User)).void }
  def initialize(user)
    @user = user
  end

  private

    sig { returns(String) }
    def namespaced_header_title
      if namespace == "moderation/budgets"
        t("moderation.header.title")
      elsif namespace == "management"
        t("management.dashboard.index.title")
      else
        t("#{namespace}.header.title")
      end
    end

    sig { returns(String) }
    def namespace_path
      if namespace == "officing"
        "#"
      else
        namespaced_root_path
      end
    end

    sig { returns(T.untyped) }
    def show_account_menu?
      show_admin_menu?(user) || namespace != "management"
    end

    sig { returns(T::Boolean) }
    def show_link_to_root_path?
      !Rails.application.multitenancy_management_mode?
    end
end
