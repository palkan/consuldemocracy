# typed: strict
class Dashboard::ActiveResourceComponent < ApplicationComponent
  sig { returns(Dashboard::Action) }
  attr_reader :resource

  sig { returns(Proposal) }
  attr_reader :proposal

  sig { returns(T.nilable(T::Array[Integer])) }
  attr_reader :new_actions_since_last_login

  delegate :is_new_action_since_last_login?, to: :helpers

  sig do
    params(
      resource: Dashboard::Action,
      proposal: Proposal,
      new_actions_since_last_login: T.nilable(T::Array[Integer])
    ).void
  end
  def initialize(resource, proposal, new_actions_since_last_login)
    @resource = resource
    @proposal = proposal
    @new_actions_since_last_login = new_actions_since_last_login
  end

  sig { returns(String) }
  def resource_card_class
    return "alert" unless resource.active_for?(proposal)
    return "success" if resource.executed_for?(proposal)

    "primary"
  end

  sig { returns(String) }
  def resource_tooltip
    return t("dashboard.resource.resource_locked") unless resource.active_for?(proposal)
    return t("dashboard.resource.view_resource") if resource.executed_for?(proposal)
    return t("dashboard.resource.resource_requested") if resource.requested_for?(proposal)

    t("dashboard.resource.request_resource")
  end

  sig { returns(ActiveSupport::SafeBuffer) }
  def resource_availability_label
    label = []

    label << t("dashboard.resource.required_days",
               days: resource.day_offset) if T.must(resource.day_offset) > 0
    label << t("dashboard.resource.required_supports",
               supports: number_with_delimiter(resource.required_supports,
                                               delimiter: ".")) if T.must(resource.required_supports) > 0

    safe_join label, h(" #{t("dashboard.resource.and")} ") + tag(:br)
  end
end
