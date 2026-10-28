# typed: strict
class Management::MenuComponent < ApplicationComponent
  delegate :managed_user, :link_list, to: :helpers

  sig { returns(T::Array[T.untyped]) }
  def links
    [
      user_links,
      (print_investments_link if Setting["process.budgets"]),
      print_proposals_link,
      user_invites_link
    ]
  end

  private

    sig { returns(ActiveSupport::SafeBuffer) }
    def user_links
      section(t("management.menu.users"), active: true, class: "users-link") do
        link_list(
          select_user_link,
          (reset_password_email_link if managed_user.email),
          reset_password_manually_link,
          create_proposal_link,
          support_proposals_link,
          (create_budget_investment_link if Setting["process.budgets"]),
          (support_budget_investments_link  if Setting["process.budgets"])
        )
      end
    end

    sig { returns(T::Array[T.untyped]) }
    def select_user_link
      [
        t("management.menu.select_user"),
        management_document_verifications_path,
        users?
      ]
    end

    sig { returns(T::Array[T.untyped]) }
    def reset_password_email_link
      [
        t("management.account.menu.reset_password_email"),
        edit_password_email_management_account_path,
        edit_password_email?
      ]
    end

    sig { returns(T::Array[T.untyped]) }
    def reset_password_manually_link
      [
        t("management.account.menu.reset_password_manually"),
        edit_password_manually_management_account_path,
        edit_password_manually?
      ]
    end

    sig { returns(T::Array[T.untyped]) }
    def create_proposal_link
      [
        t("management.menu.create_proposal"),
        new_management_proposal_path,
        create_proposal?
      ]
    end

    sig { returns(T::Array[T.untyped]) }
    def support_proposals_link
      [
        t("management.menu.support_proposals"),
        management_proposals_path,
        support_proposal?
      ]
    end

    sig { returns(T::Array[T.untyped]) }
    def create_budget_investment_link
      [
        t("management.menu.create_budget_investment"),
        create_investments_management_budgets_path,
        create_investments?
      ]
    end

    sig { returns(T::Array[T.untyped]) }
    def support_budget_investments_link
      [
        t("management.menu.support_budget_investments"),
        support_investments_management_budgets_path,
        support_investments?
      ]
    end

    sig { returns(T::Array[T.untyped]) }
    def print_investments_link
      [
        t("management.menu.print_budget_investments"),
        print_investments_management_budgets_path,
        print_investments?,
        class: "print-investments-link"
      ]
    end

    sig { returns(T::Array[T.untyped]) }
    def print_proposals_link
      [
        t("management.menu.print_proposals"),
        print_management_proposals_path,
        print_proposals?,
        class: "print-proposals-link"
      ]
    end

    sig { returns(T::Array[T.untyped]) }
    def user_invites_link
      [
        t("management.menu.user_invites"),
        new_management_user_invite_path,
        user_invites?,
        class: "invitations-link"
      ]
    end

    sig { returns(T::Boolean) }
    def users?
      ["users", "email_verifications", "document_verifications"].include?(controller_name)
    end

    sig { returns(T::Boolean) }
    def edit_password_email?
      controller_name == "account" && action_name == "edit_password_email"
    end

    sig { returns(T::Boolean) }
    def edit_password_manually?
      controller_name == "account" && action_name == "edit_password_manually"
    end

    sig { returns(T::Boolean) }
    def create_proposal?
      controller_name == "proposals" && action_name == "new"
    end

    sig { returns(T::Boolean) }
    def support_proposal?
      controller_name == "proposals" && action_name == "index"
    end

    sig { returns(T::Boolean) }
    def print_proposals?
      controller_name == "proposals" && action_name == "print"
    end

    sig { returns(T::Boolean) }
    def create_investments?
      (controller_name == "budget_investments" && action_name == "new") ||
        (controller_name == "budgets" && action_name == "create_investments")
    end

    sig { returns(T::Boolean) }
    def support_investments?
      (controller_name == "budget_investments" && action_name == "index") ||
        (controller_name == "budgets" && action_name == "support_investments")
    end

    sig { returns(T::Boolean) }
    def print_investments?
      (controller_name == "budget_investments" && action_name == "print") ||
        (controller_name == "budgets" && action_name == "print_investments")
    end

    sig { returns(T::Boolean) }
    def user_invites?
      controller_name == "user_invites"
    end

    sig do
      params(
        title: String,
        active: T::Boolean,
        options: T.untyped,
        content: T.proc.returns(String)
      ).returns(ActiveSupport::SafeBuffer)
    end
    def section(title, active:, **options, &content)
      section_opener(title, active: active, options: options) + content.call
    end

    sig do
      params(title: String, active: T::Boolean, options: T::Hash[Symbol, T.untyped])
        .returns(ActiveSupport::SafeBuffer)
    end
    def section_opener(title, active:, options:)
      button_tag(title, { type: "button", disabled: "disabled", "aria-expanded": active }.merge(options))
    end
end
