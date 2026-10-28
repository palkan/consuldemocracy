# typed: strict
class Shared::VoteButtonComponent < ApplicationComponent
  sig { returns(T.any(Comment, Debate, Legislation::Proposal)) }
  attr_reader :votable

  sig { returns(String) }
  attr_reader :value

  sig { returns(T::Hash[Symbol, T.untyped]) }
  attr_reader :options

  sig do
    params(votable: T.any(Comment, Debate, Legislation::Proposal), value: String, options: T.untyped).void
  end
  def initialize(votable, value:, **options)
    @votable = votable
    @value = value
    @options = options
    @vote = T.let(nil, T.nilable(Vote))
  end

  private

    sig { returns(String) }
    def path
      if already_voted?
        polymorphic_path(vote)
      else
        polymorphic_path(vote, value: value)
      end
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def default_options
      if already_voted?
        {
          "aria-pressed": true,
          method: :delete,
          remote: can?(:destroy, vote)
        }
      else
        {
          "aria-pressed": false,
          method: :post,
          remote: can?(:create, vote)
        }
      end
    end

    sig { returns(Vote) }
    def vote
      @vote ||= Vote.find_or_initialize_by(votable: votable, voter: current_user, vote_flag: in_favor?)
    end

    sig { returns(T::Boolean) }
    def already_voted?
      vote.persisted?
    end

    sig { returns(T::Boolean) }
    def in_favor?
      value == "yes"
    end
end
