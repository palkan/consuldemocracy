# typed: strict
class Users::PublicActivityComponent < ApplicationComponent
  sig { returns(User) }
  attr_reader :user

  delegate :valid_interests_access?, :current_path_with_query_params, to: :helpers

  sig { params(user: User).void }
  def initialize(user)
    @user = user
    @valid_filters = T.let(nil, T.nilable(T::Array[String]))
    @follows = T.let(nil, T.nilable(T::Array[Follow]))
  end

  sig { returns(T.nilable(T::Boolean)) }
  def valid_access?
    user.public_activity || authorized_current_user?
  end

  sig { returns(T.nilable(String)) }
  def current_filter
    if valid_filters.include?(params[:filter])
      params[:filter]
    else
      valid_filters.first
    end
  end

  sig { returns(T::Array[String]) }
  def valid_filters
    @valid_filters ||= [
      ("proposals" if feature?(:proposals)),
      ("debates" if feature?(:debates)),
      ("budget_investments" if feature?(:budgets)),
      "comments",
      ("follows" if valid_interests_access?(user))
    ].compact.select { |filter| send(filter).any? }
  end

  private

    sig { returns(T.nilable(T::Boolean)) }
    def authorized_current_user?
      current_user == user || current_user&.moderator? || current_user&.administrator?
    end

    sig { returns(Proposal::PrivateRelation) }
    def proposals
      Proposal.where(author_id: user.id)
    end

    sig { returns(Debate::PrivateRelation) }
    def debates
      Debate.where(author_id: user.id)
    end

    sig { returns(Comment::PrivateRelation) }
    def comments
      Comment.not_valuations
             .not_as_admin_or_moderator
             .where(user_id: user.id)
             .where.not(commentable_type: disabled_commentables)
             .includes(:commentable)
    end

    sig { returns(Budget::Investment::PrivateRelation) }
    def budget_investments
      Budget::Investment.where(author_id: user.id)
    end

    sig { returns(T::Array[Follow]) }
    def follows
      @follows ||= user.follows.select { |follow| follow.followable.present? }
    end

    sig { params(filter: String).returns(Integer) }
    def count(filter)
      send(filter).count
    end

    sig { params(filter: String).returns(String) }
    def render_user_partial(filter)
      render "users/#{filter}", "#{filter}": send(filter).order(created_at: :desc).page(page)
    end

    sig { returns(T.untyped) }
    def page
      params[:page]
    end

    sig { returns(T::Array[String]) }
    def disabled_commentables
      [
        ("Debate" unless feature?(:debates)),
        ("Budget::Investment" unless feature?(:budgets)),
        (["Legislation::Question",
          "Legislation::Proposal",
          "Legislation::Annotation"] unless feature?(:legislation)),
        (["Poll", "Poll::Question"] unless feature?(:polls)),
        ("Proposal" unless feature?(:proposals))
      ].flatten.compact
    end
end
