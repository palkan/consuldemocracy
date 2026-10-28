# typed: strict
class Dashboard::Action < ApplicationRecord
  include Documentable
  include Linkable

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  has_many :executed_actions, dependent: :restrict_with_error,
                              class_name: "Dashboard::ExecutedAction"
  has_many :proposals, through: :executed_actions

  enum :action_type, { proposed_action: 0, resource: 1 }

  validates :title, presence: true, allow_blank: false, length: { in: 4..80 }

  validates :action_type, presence: true

  validates :day_offset,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0
            }

  validates :required_supports,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0
            }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :resources, -> { where(action_type: 1) }
  scope :proposed_actions, -> { where(action_type: 0) }
  scope :by_proposal, ->(proposal) { where(published_proposal: false) if proposal.draft? }
  scope :by_published_proposal, ->(published) { where(published_proposal: published) }

  sig do
    params(proposal: Proposal)
      .returns(T.any(Dashboard::Action::PrivateRelation, Dashboard::Action::PrivateAssociationRelation))
  end
  def self.active_for(proposal)
    published_at = proposal.published_at&.to_date || Date.current

    active.where(required_supports: ..proposal.cached_votes_up)
          .where(day_offset: ..(Date.current - published_at).to_i)
          .by_proposal(proposal)
  end

  sig do
    params(proposal: Proposal)
      .returns(T.any(Dashboard::Action::PrivateRelation, Dashboard::Action::PrivateAssociationRelation))
  end
  def self.course_for(proposal)
    active
      .resources
      .where("required_supports > ?", proposal.cached_votes_up)
      .order(required_supports: :asc)
  end

  sig { params(proposal: Proposal).returns(T::Boolean) }
  def active_for?(proposal)
    published_at = proposal.published_at&.to_date || Date.current

    T.must(required_supports) <= T.must(proposal.cached_votes_up) &&
      T.must(day_offset) <= (Date.current - published_at).to_i
  end

  sig { params(proposal: Proposal).returns(T::Boolean) }
  def requested_for?(proposal)
    executed_action = executed_actions.find_by(proposal: proposal)
    return false if executed_action.nil?

    executed_action.administrator_tasks.any?
  end

  sig { params(proposal: Proposal).returns(T::Boolean) }
  def executed_for?(proposal)
    executed_action = executed_actions.find_by(proposal: proposal)
    return false if executed_action.nil?

    executed_action.administrator_tasks.where.not(executed_at: nil).any?
  end

  sig { params(proposal: Proposal).returns(T.nilable(Dashboard::Action)) }
  def self.next_goal_for(proposal)
    course_for(proposal).first
  end

  sig { params(date: Date, proposal: Proposal).returns(T::Array[Integer]) }
  def self.detect_new_actions_since(date, proposal)
    actions_for_today = get_actions_for_today(proposal)
    actions_for_date = get_actions_for_date(proposal, date)

    actions_for_today.ids - actions_for_date.ids
  end

  private

    sig { params(proposal: Proposal).returns(Dashboard::Action::PrivateRelation) }
    def self.get_actions_for_today(proposal)
      proposal_votes = proposal.cached_votes_up
      day_offset = calculate_day_offset(proposal, Date.current)

      calculate_actions(proposal_votes, day_offset, proposal)
    end

    sig { params(proposal: Proposal, date: Date).returns(Dashboard::Action::PrivateRelation) }
    def self.get_actions_for_date(proposal, date)
      proposal_votes = calculate_votes(proposal, date)
      day_offset = calculate_day_offset(proposal, date)

      calculate_actions(proposal_votes, day_offset, proposal)
    end

    sig { params(proposal: Proposal, date: Date).returns(Integer) }
    def self.calculate_day_offset(proposal, date)
      start_date = proposal.published? ? proposal.published_at : proposal.created_at
      T.cast(date - T.must(start_date).to_date, Rational).to_i
    end

    sig do
      params(proposal_votes: T.nilable(Integer), day_offset: Integer, proposal: Proposal)
        .returns(Dashboard::Action::PrivateRelation)
    end
    def self.calculate_actions(proposal_votes, day_offset, proposal)
      Dashboard::Action.active
                       .where(required_supports: ..proposal_votes)
                       .where(day_offset: ..day_offset)
                       .by_published_proposal(proposal.published?)
    end

    sig { params(proposal: Proposal, date: Date).returns(Integer) }
    def self.calculate_votes(proposal, date)
      Vote.where(votable: proposal).where(created_at: ..date).count
    end
end
