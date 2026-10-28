# typed: strict
class Proposals::SupportsComponent < ApplicationComponent
  sig { returns(Proposal) }
  attr_reader :proposal

  sig { params(proposal: Proposal).void }
  def initialize(proposal)
    @proposal = proposal
  end

  private

    sig { returns(Integer) }
    def progress_bar_percentage
      percentage.floor
    end

    sig { returns(T.nilable(String)) }
    def supports_percentage
      number_to_percentage(percentage, strip_insignificant_zeros: true, precision: 1)
    end

    sig { returns(Numeric) }
    def percentage
      if real_percentage > 0 && real_percentage < 0.1
        0.1
      else
        real_percentage
      end
    end

    sig { returns(Numeric) }
    def real_percentage
      [
        proposal.total_votes.to_f * 100 / Proposal.votes_needed_for_success,
        100
      ].min
    end
end
