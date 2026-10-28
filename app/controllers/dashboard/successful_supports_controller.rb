# typed: true
class Dashboard::SuccessfulSupportsController < Dashboard::BaseController
  include Dashboard::ExpectsDateRange
  include Dashboard::GroupSupports

  sig { void }
  def index
    authorize! :dashboard, proposal
    render json: accumulated_grouped_supports
  end

  private

    sig { returns(T::Hash[T.any(String, Date), T.untyped]) }
    def accumulated_grouped_supports
      grouped_votes = grouped_supports(:voted_at)
      grouped_votes = fill_holes(grouped_votes)
      accumulate_supports(grouped_votes)
    end

    sig { override.returns(T.any(T::Array[Vote], Vote::PrivateRelation)) }
    def supports
      return [] if successful_proposal.nil?

      Vote
        .select("created_at + interval '#{days_diff} day' voted_at, *")
        .where(votable: successful_proposal)
        .where("created_at + interval '#{days_diff} day' between ? and ?",
               start_date.beginning_of_day, end_date.end_of_day)
        .order(created_at: :asc)
    end

    sig { returns(T.nilable(Proposal)) }
    def successful_proposal
      return @successful_proposal if defined?(@successful_proposal)

      @successful_proposal = Proposal.find_by(id: Setting["proposals.successful_proposal_id"])
    end

    sig { returns(Integer) }
    def days_diff
      successful_proposal = self.successful_proposal
      published_at = proposal.published_at
      return 0 if successful_proposal.nil?
      return 0 if published_at.nil?

      (published_at.to_date - T.must(successful_proposal.published_at).to_date).to_i
    end
end
