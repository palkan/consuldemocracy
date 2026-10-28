# typed: strict
module Admin::ProposalDashboardActionsHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params(active: T.nilable(T::Boolean)).returns(String) }
  def active_human_readable(active)
    return t("admin.dashboard.actions.index.active") if active

    t("admin.dashboard.actions.index.inactive")
  end

  sig { returns(T::Array[String]) }
  def default_actions
    %w[polls email poster]
  end
end
