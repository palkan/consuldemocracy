# typed: strict
module ProposalsDashboardHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { returns(T::Boolean) }
  def my_proposal_menu_active?
    controller_name == "dashboard" && action_name == "show"
  end

  sig { returns(T::Boolean) }
  def community_menu_active?
    controller_name == "dashboard" && action_name == "community"
  end

  sig { returns(T::Boolean) }
  def messages_menu_active?
    controller_name == "dashboard" && action_name == "messages"
  end

  sig { returns(T::Boolean) }
  def related_content_menu_active?
    controller_name == "dashboard" && action_name == "related_content"
  end

  sig { returns(T::Boolean) }
  def progress_menu_active?
    is_proposed_action_request? || (controller_name == "dashboard" && action_name == "progress")
  end

  sig { returns(T::Boolean) }
  def recommended_actions_menu_active?
    controller_name == "dashboard" && action_name == "recommended_actions"
  end

  sig { params(proposal: Proposal, resources: T::Enumerable[Dashboard::Action]).returns(T::Boolean) }
  def resources_menu_visible?(proposal, resources)
    can?(:manage_polls, proposal) || resources.any?
  end

  sig { returns(T.nilable(T::Boolean)) }
  def resources_menu_active?
    poster_menu_active? || polls_menu_active? || mailing_menu_active? || is_resource_request?
  end

  sig { returns(T::Boolean) }
  def polls_menu_active?
    controller_name == "polls"
  end

  sig { returns(T::Boolean) }
  def poster_menu_active?
    controller_name == "poster"
  end

  sig { returns(T::Boolean) }
  def mailing_menu_active?
    controller_name == "mailing"
  end

  sig { returns(T.nilable(T::Boolean)) }
  def is_resource_request?
    controller_name == "dashboard" && action_name == "new_request" && dashboard_action&.resource?
  end

  sig { returns(T.nilable(T::Boolean)) }
  def is_proposed_action_request?
    controller_name == "dashboard" && action_name == "new_request" &&
      dashboard_action&.proposed_action?
  end

  sig { params(id: Integer).returns(T.nilable(T::Boolean)) }
  def request_active?(id)
    controller_name == "dashboard" && action_name == "new_request" && dashboard_action&.id == id
  end

  sig { returns(T.nilable(String)) }
  def daily_selected_class
    return nil if params[:group_by].blank?

    "hollow"
  end

  sig { returns(T.nilable(String)) }
  def weekly_selected_class
    return nil if params[:group_by] == "week"

    "hollow"
  end

  sig { returns(T.nilable(String)) }
  def monthly_selected_class
    return nil if params[:group_by] == "month"

    "hollow"
  end

  sig { params(proposed_action: Dashboard::Action).returns(T.nilable(ActiveSupport::SafeBuffer)) }
  def proposed_action_description(proposed_action)
    sanitize T.must(proposed_action.description).truncate(200)
  end

  sig { params(proposed_action: Dashboard::Action).returns(T::Boolean) }
  def proposed_action_long_description?(proposed_action)
    T.must(proposed_action.description).length > 200
  end

  sig do
    params(proposed_action: Dashboard::Action, new_actions_since_last_login: T.nilable(T::Array[Integer]))
      .returns(T.nilable(T::Boolean))
  end
  def is_new_action_since_last_login?(proposed_action, new_actions_since_last_login)
    new_actions_since_last_login.presence&.include?(proposed_action.id)
  end

  sig do
    params(
      resources: T.nilable(
        T.any(Dashboard::Action::PrivateRelation, Dashboard::Action::PrivateAssociationRelation)
      ),
      new_actions_since_last_login: T::Array[Integer]
    ).returns(T::Boolean)
  end
  def new_resources_since_last_login?(resources, new_actions_since_last_login)
    resources.present? &&
      resources.ids.any? { |id| new_actions_since_last_login.include?(id) }
  end

  sig { params(proposal: Proposal).returns(Integer) }
  def active_resources_for(proposal)
    default_resources_count = 3 #resources: mail, poster, poll
    Dashboard::Action.active.resources.active_for(proposal).count + default_resources_count
  end

  sig { params(proposal: Proposal).returns(Integer) }
  def active_resources_count(proposal)
    default_resources_count = 3 #resources: mail, poster, poll
    Dashboard::Action.active.resources.by_proposal(proposal).count + default_resources_count
  end
end
