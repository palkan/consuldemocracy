# typed: strict
class Moderation::MenuComponent < ApplicationComponent
  delegate :link_list, to: :helpers

  sig { returns(T::Array[T.nilable(T::Array[T.untyped])]) }
  def links
    [
      moderation_root_link,
      (proposals_link if feature?(:proposals)),
      (proposal_notifications_link if feature?(:proposals)),
      (debates_link if feature?(:debates)),
      (budget_investments_link if feature?(:budgets)),
      (legislation_proposals_link if feature?(:legislation)),
      comments_link,
      users_link
    ]
  end

  private

    sig { returns(T::Array[String]) }
    def moderation_root_link
      [t("moderation.dashboard.index.title"), moderation_root_path]
    end

    sig { returns(T::Array[T.untyped]) }
    def proposals_link
      [
        t("moderation.menu.proposals"),
        moderation_proposals_path,
        controller_name == "proposals" && !legislation?,
        class: "proposals-link"
      ]
    end

    sig { returns(T::Array[T.untyped]) }
    def proposal_notifications_link
      [
        t("moderation.menu.proposal_notifications"),
        moderation_proposal_notifications_path,
        controller_name == "proposal_notifications",
        class: "proposal-notifications-link"
      ]
    end

    sig { returns(T::Array[T.untyped]) }
    def debates_link
      [
        t("moderation.menu.flagged_debates"),
        moderation_debates_path,
        controller_name == "debates",
        class: "debates-link"
      ]
    end

    sig { returns(T::Array[T.untyped]) }
    def budget_investments_link
      [
        t("moderation.menu.flagged_investments"),
        moderation_budget_investments_path,
        controller_name == "investments",
        class: "investments-link"
      ]
    end

    sig { returns(T::Array[T.untyped]) }
    def comments_link
      [
        t("moderation.menu.flagged_comments"),
        moderation_comments_path,
        controller_name == "comments",
        class: "comments-link"
      ]
    end

    sig { returns(T::Array[T.untyped]) }
    def users_link
      [
        t("moderation.menu.users"),
        moderation_users_path,
        controller_name == "users",
        class: "users-link"
      ]
    end

    sig { returns(T::Array[T.untyped]) }
    def legislation_proposals_link
      [
        t("sdg_management.menu.legislation_proposals"),
        moderation_legislation_proposals_path,
        legislation?,
        class: "legislation-link"
      ]
    end

    sig { returns(T::Boolean) }
    def legislation?
      controller_path.split("/").include?("legislation")
    end
end
