# typed: true
module ProposalsHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }
  requires_ancestor { AdminHelper }
  requires_ancestor { ApplicationHelper }

  sig { params(proposal: Proposal, options: T::Hash[Symbol, T.untyped]).returns(String) }
  def namespaced_proposal_path(proposal, options = {})
    @namespace_proposal_path ||= namespace
    case @namespace_proposal_path
    when "management"
      management_proposal_path(proposal, options)
    else
      proposal_path(proposal, options)
    end
  end

  sig { returns(T::Array[[String, String]]) }
  def retire_proposals_options
    Proposal::RETIRE_OPTIONS.map { |option| [t("proposals.retire_options.#{option}"), option] }
  end

  sig { params(user: User).returns(String) }
  def empty_recommended_proposals_message_text(user)
    if user.interests.any?
      t("proposals.index.recommendations.without_results")
    else
      t("proposals.index.recommendations.without_interests")
    end
  end

  sig { params(proposal: Proposal).returns(T::Boolean) }
  def author_of_proposal?(proposal)
    author_of?(proposal, current_user)
  end

  sig { params(proposal: Proposal).returns(T.nilable(T::Boolean)) }
  def current_editable?(proposal)
    user = current_user
    user && proposal.editable_by?(user)
  end

  sig { returns(T::Boolean) }
  def show_proposal_votes?
    params[:selected].blank?
  end

  sig { returns(T::Boolean) }
  def show_recommended_proposals?
    params[:selected].blank?
  end
end
