# typed: strict
module ScoreCalculator
  extend T::Sig

  sig { params(resource: T.any(Debate, Proposal, Legislation::Proposal)).returns(Integer) }
  def self.hot_score(resource)
    # `created_at` is still `nil` when the score is calculated before creating the record
    created_at = T.let(resource.created_at, T.nilable(ActiveSupport::TimeWithZone))
    return 0 unless created_at

    period = [1, [max_period, resource_age(resource)].min].max

    votes_total = resource.votes_for.where(created_at: period.days.ago..).count
    votes_up    = resource.get_up_votes.where(created_at: period.days.ago..).count
    votes_down  = votes_total - votes_up
    votes_score = votes_up - votes_down

    (votes_score.to_f / period).round
  end

  sig { params(votes_total: Integer, votes_up: Integer).returns(T.any(Integer, Float)) }
  def self.confidence_score(votes_total, votes_up)
    return 1 if votes_total.zero?

    votes_total = votes_total.to_f
    votes_up    = votes_up.to_f
    votes_down  = votes_total - votes_up
    score       = votes_up - votes_down

    score * (votes_up / votes_total) * 100
  end

  sig { returns(Integer) }
  def self.max_period
    Setting["hot_score_period_in_days"].to_i
  end

  sig { params(resource: T.any(Debate, Proposal, Legislation::Proposal)).returns(Integer) }
  def self.resource_age(resource)
    ((Time.current - resource.created_at) / 1.day).ceil
  end
end
