# typed: strict
class Activity < ApplicationRecord
  # The scopes run on the relations of the associated classes
  belongs_to :actionable, -> { T.bind(self, T.untyped).with_hidden }, polymorphic: true
  belongs_to :user, -> { T.bind(self, T.untyped).with_hidden }, inverse_of: :activities

  VALID_ACTIONS = %w[hide block restore valuate email].freeze

  validates :action, inclusion: { in: ->(*) { VALID_ACTIONS }}

  scope :on_proposals, -> { where(actionable_type: "Proposal") }
  scope :on_debates, -> { where(actionable_type: "Debate") }
  scope :on_users, -> { where(actionable_type: "User") }
  scope :on_comments, -> { where(actionable_type: "Comment") }
  scope :on_budget_investments, -> { where(actionable_type: "Budget::Investment") }
  scope :on_system_emails, -> { where(actionable_type: "ProposalNotification") }
  scope :for_render, -> { includes(user: [:moderator, :administrator]).includes(:actionable) }

  sig do
    params(user: T.nilable(User), action: T.any(String, Symbol), actionable: T.untyped)
      .returns(Activity)
  end
  def self.log(user, action, actionable)
    create!(user: user, action: action.to_s, actionable: actionable)
  end

  sig { params(actionable: T.untyped).returns(Activity::PrivateRelation) }
  def self.on(actionable)
    where(actionable: actionable)
  end

  sig { params(user: T.nilable(User)).returns(Activity::PrivateRelation) }
  def self.by(user)
    where(user: user)
  end
end
