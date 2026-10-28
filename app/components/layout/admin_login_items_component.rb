# typed: strict
class Layout::AdminLoginItemsComponent < ApplicationComponent
  sig { returns(T.nilable(User)) }
  attr_reader :user

  delegate :link_list, :show_admin_menu?, to: :helpers

  sig { params(user: T.nilable(User)).void }
  def initialize(user)
    @user = user
  end

  sig { returns(T.untyped) }
  def render?
    show_admin_menu?(user) && !Rails.application.multitenancy_management_mode?
  end

  private

    sig { returns(T::Array[T.nilable(T::Array[String])]) }
    def admin_links
      user = T.must(self.user)

      [
        (admin_link if user.administrator?),
        (moderation_link if user.administrator? || user.moderator?),
        (valuation_link if feature?(:budgets) && (user.administrator? || user.valuator?)),
        (management_link if user.administrator? || user.manager?),
        (officing_link if user.poll_officer?),
        (sdg_management_link if feature?(:sdg) && (user.administrator? || user.sdg_manager?))
      ]
    end

    sig { returns(T::Array[String]) }
    def admin_link
      [t("layouts.header.administration"), admin_root_path]
    end

    sig { returns(T::Array[String]) }
    def moderation_link
      [t("layouts.header.moderation"), moderation_root_path]
    end

    sig { returns(T::Array[String]) }
    def valuation_link
      [t("layouts.header.valuation"), valuation_root_path]
    end

    sig { returns(T::Array[String]) }
    def management_link
      [t("layouts.header.management"), management_root_path]
    end

    sig { returns(T::Array[String]) }
    def officing_link
      [t("layouts.header.officing"), officing_root_path]
    end

    sig { returns(T::Array[String]) }
    def sdg_management_link
      [t("sdg_management.header.title"), sdg_management_root_path]
    end
end
