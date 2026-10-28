# typed: strict
module Dashboard::ExpectsDateRange
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ActionController::Base }

  include Dashboard::HasProposal

  sig { params(fallback_date: Date).returns(Date) }
  def start_date(fallback_date = proposal.created_at.to_date)
    return Date.parse(params[:start_date]) if params[:start_date].present?

    fallback_date
  end

  sig { returns(Date) }
  def end_date
    return Date.parse(params[:end_date]) if params[:end_date].present?

    Date.current
  end
end
