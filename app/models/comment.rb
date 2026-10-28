# typed: true
class Comment < ApplicationRecord
  include Flaggable
  include HasPublicAuthor
  include Graphqlable
  include Notifiable
  include Searchable

  COMMENTABLE_TYPES = T.let(%w[Debate Proposal Budget::Investment Poll Topic
                               Legislation::Question Legislation::Annotation
                               Legislation::Proposal].freeze, T::Array[String])

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  acts_as_votable
  has_ancestry touch: true

  # `typed: true`: strict mode requires declaring these instance variables in `initialize`
  sig { returns(T.untyped) }
  attr_accessor :as_moderator

  sig { returns(T.untyped) }
  attr_accessor :as_administrator

  translates :body, touch: true
  include Globalizable

  validates_translation :body, presence: true
  validates :user, presence: true

  validates :commentable_type, inclusion: { in: ->(*) { COMMENTABLE_TYPES }}

  validate :validate_body_length
  validate :comment_valuation, if: :valuation

  belongs_to :commentable, -> { with_hidden }, polymorphic: true, counter_cache: true, touch: true
  belongs_to :user, -> { with_hidden }, inverse_of: :comments

  before_save :calculate_confidence_score

  scope :for_render, -> { with_hidden.includes(user: :organization) }
  scope :with_visible_author, -> { joins(:user).where(users: { hidden_at: nil }) }
  scope :not_as_admin_or_moderator, -> { where(administrator_id: nil).where(moderator_id: nil) }
  scope :sort_by_flags, -> { order(flags_count: :desc, updated_at: :desc) }
  scope :public_for_api, -> do
    not_valuations
      .where(commentable: [Debate.public_for_api,
                           Proposal.public_for_api,
                           Poll.public_for_api,
                           Budget::Investment.public_for_api])
  end

  scope :sort_by_most_voted, -> { order(confidence_score: :desc, created_at: :desc) }
  scope :sort_descendants_by_most_voted, -> { order(confidence_score: :desc, created_at: :asc) }
  scope :sort_by_supports, -> { order(Arel.sql("cached_votes_up - cached_votes_down DESC")) }

  scope :sort_by_newest, -> { order(created_at: :desc) }
  scope :sort_descendants_by_newest, -> { order(created_at: :desc) }

  scope :sort_by_oldest, -> { order(created_at: :asc) }
  scope :sort_descendants_by_oldest, -> { order(created_at: :asc) }

  scope :not_valuations, -> { where(valuation: false) }

  after_create :call_after_commented

  sig do
    params(
      commentable: T.untyped,
      user: User,
      body: T.nilable(String),
      p_id: T.nilable(T.any(String, Integer)),
      valuation: T.nilable(T.any(T::Boolean, String))
    ).returns(Comment)
  end
  def self.build(commentable, user, body, p_id = nil, valuation = false)
    new(commentable: commentable,
        user_id: user.id,
        body: body,
        parent_id: p_id,
        valuation: valuation)
  end

  sig { params(c_type: String, c_id: T.any(String, Integer)).returns(T.untyped) }
  def self.find_commentable(c_type, c_id)
    c_type.constantize.find(c_id)
  end

  sig { returns(T.nilable(Integer)) }
  def author_id
    user_id
  end

  sig { returns(T.nilable(User)) }
  def author
    user
  end

  sig { params(author: T.nilable(User)).void }
  def author=(author)
    self.user = author
  end

  sig { returns(String) }
  def human_name
    body.truncate(32)
  end

  sig { returns(T.nilable(Integer)) }
  def total_votes
    cached_votes_total
  end

  sig { returns(T.nilable(Integer)) }
  def total_likes
    cached_votes_up
  end

  sig { returns(T.nilable(Integer)) }
  def total_dislikes
    cached_votes_down
  end

  sig { returns(T::Boolean) }
  def as_administrator?
    administrator_id.present?
  end

  sig { returns(T::Boolean) }
  def as_moderator?
    moderator_id.present?
  end

  sig { void }
  def after_hide
    T.must(commentable_type).constantize.with_hidden.reset_counters(commentable_id, :comments)
  end

  sig { void }
  def after_restore
    T.must(commentable_type).constantize.with_hidden.reset_counters(commentable_id, :comments)
  end

  sig { returns(T::Boolean) }
  def reply?
    !root?
  end

  sig { void }
  def call_after_commented
    commentable.after_commented if commentable.respond_to?(:after_commented)
  end

  sig { returns(Integer) }
  def self.body_max_length
    Setting["comments_body_max_length"].to_i
  end

  sig { void }
  def calculate_confidence_score
    self.confidence_score = ScoreCalculator.confidence_score(T.must(cached_votes_total),
                                                             T.must(cached_votes_up)).to_i
  end

  sig { returns(Integer) }
  def votes_score
    T.must(cached_votes_up) - T.must(cached_votes_down)
  end

  sig { returns(T::Hash[T.untyped, String]) }
  def searchable_values
    {
      body => "A",
      commentable&.title => "B"
    }
  end

  sig { params(terms: T.nilable(String)).returns(Comment::PrivateRelation) }
  def self.search(terms)
    pg_search(terms)
  end

  private

    sig { void }
    def validate_body_length
      validator = ActiveModel::Validations::LengthValidator.new(
        attributes: :body,
        maximum: Comment.body_max_length
      )
      validator.validate(self)
    end

    sig { void }
    def comment_valuation
      unless T.must(author).can?(:comment_valuation, commentable)
        errors.add(:valuation, :cannot_comment_valuation)
      end
    end
end
