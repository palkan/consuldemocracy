# typed: true
class Dashboard::SupportsController < Dashboard::BaseController
  include Dashboard::ExpectsDateRange
  include Dashboard::GroupSupports

  sig { void }
  def index
    authorize! :dashboard, proposal
    render json: accumulated_supports
  end

  private

    sig { returns(T::Hash[T.any(String, Date), T.untyped]) }
    def accumulated_supports
      grouped_votes = grouped_supports(:created_at)
      grouped_votes = fill_holes(grouped_votes)
      accumulate_supports(grouped_votes)
    end

    sig { override.returns(Vote::PrivateRelation) }
    def supports
      @supports ||= Vote
                    .where(votable: proposal,
                           created_at: start_date.beginning_of_day..end_date.end_of_day)
                    .order(created_at: :asc)
    end
end
