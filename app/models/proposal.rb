# typed: strict
class Proposal < ApplicationRecord
  include Flaggable
  include Taggable
  include Conflictable
  include Measurable
  include Searchable
  include Filterable
  include HasPublicAuthor
  include Graphqlable
  include Followable
  include Communitable
  include Imageable
  include Mappable
  include Notifiable
  include Documentable
  include Videoable
  include Relationable
  include Milestoneable
  include Randomizable
  include SDG::Relatable

  acts_as_votable
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  RETIRE_OPTIONS = %w[duplicated started unfeasible done other].freeze

  translates :title, touch: true
  translates :description, touch: true
  translates :summary, touch: true
  translates :retired_explanation, touch: true
  include Globalizable

  translation_class_delegate :retired_at

  belongs_to :author, -> { with_hidden }, class_name: "User", inverse_of: :proposals
  belongs_to :geozone
  has_many :comments, as: :commentable, inverse_of: :commentable, dependent: :destroy
  has_many :proposal_notifications, dependent: :destroy
  has_many :dashboard_executed_actions, dependent: :destroy, class_name: "Dashboard::ExecutedAction"
  has_many :dashboard_actions, through: :dashboard_executed_actions, class_name: "Dashboard::Action"
  has_many :polls, as: :related, inverse_of: :related
  has_one :summary_comment, as: :commentable, class_name: "MlSummaryComment", dependent: :destroy

  validates_translation :title, presence: true, length: { in: 4..Proposal.title_max_length }
  validates_translation :description, length: { maximum: Proposal.description_max_length }
  validates_translation :summary, presence: true
  validates_translation :retired_explanation,
                        presence: true,
                        unless: ->(record) { record.retired_at.blank? }

  validates :author, presence: true
  validates :responsible_name, presence: true, unless: :skip_user_verification?

  validates :responsible_name,
            length: { in: 6..Proposal.responsible_name_max_length },
            unless: :skip_user_verification?
  validates :retired_reason,
            presence: true,
            inclusion: { in: ->(*) { RETIRE_OPTIONS }},
            unless: ->(record) { record.retired_at.blank? }

  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  before_validation :set_responsible_name

  before_save :calculate_hot_score, :calculate_confidence_score

  after_commit :send_new_actions_notification_on_create, on: :create

  scope :for_render,               -> { includes(:tags) }
  scope :sort_by_hot_score,        -> { reorder(hot_score: :desc) }
  scope :sort_by_confidence_score, -> { reorder(confidence_score: :desc) }
  scope :sort_by_created_at,       -> { reorder(created_at: :desc) }
  scope :sort_by_most_commented,   -> { reorder(comments_count: :desc) }
  scope :sort_by_relevance,        -> { all }
  scope :sort_by_flags,            -> { order(flags_count: :desc, updated_at: :desc) }
  scope :sort_by_archival_date,    -> { archived.sort_by_confidence_score }
  scope :sort_by_recommendations,  -> { order(cached_votes_up: :desc) }

  scope :archived,       -> { where(created_at: ...Setting.archived_proposals_date_limit) }
  scope :not_archived,   -> { where(created_at: Setting.archived_proposals_date_limit..) }
  scope :last_week,      -> { where(created_at: 7.days.ago..) }
  scope :retired,        -> { where.not(retired_at: nil) }
  scope :not_retired,    -> { where(retired_at: nil) }
  scope :successful,     -> { where(cached_votes_up: Proposal.votes_needed_for_success..) }
  scope :unsuccessful,   -> { where(cached_votes_up: ...Proposal.votes_needed_for_success) }
  scope :public_for_api, -> { all }
  scope :selected,       -> { where(selected: true) }
  scope :not_selected,   -> { where(selected: false) }
  scope :published,      -> { where.not(published_at: nil) }
  scope :draft,          -> { where(published_at: nil) }

  scope :not_supported_by_user, ->(user) { where.not(id: user.find_voted_items(votable_type: "Proposal")) }

  sig { void }
  def publish
    update!(published_at: Time.current)
    send_new_actions_notification_on_published
  end

  sig { returns(T::Boolean) }
  def published?
    !published_at.nil?
  end

  sig { returns(T::Boolean) }
  def draft?
    published_at.nil?
  end

  sig { params(user: User).returns(T.any(Proposal::PrivateRelation, Proposal::PrivateAssociationRelation)) }
  def self.recommendations(user)
    tagged_with(user.interests, any: true)
      .where.not(author_id: user.id)
      .unsuccessful
      .excluding(followed_by_user(user))
      .not_archived
      .not_supported_by_user(user)
  end

  sig { returns(String) }
  def to_param
    "#{id}-#{title}".parameterize
  end

  sig { returns(T::Hash[T.nilable(String), String]) }
  def searchable_translations_definitions
    { title => "A",
      summary => "C",
      description => "D" }
  end

  sig { returns(T::Hash[T.nilable(String), String]) }
  def searchable_values
    {
      T.must(author).username => "B",
      tag_list.join(" ") => "B",
      geozone&.name => "B"
    }.merge!(searchable_globalized_values)
  end

  sig do
    params(terms: String).returns(T.any(Proposal::PrivateRelation, Proposal::PrivateAssociationRelation))
  end
  def self.search(terms)
    by_code = search_by_code(terms.strip)
    by_code.presence || pg_search(terms)
  end

  sig do
    params(terms: String)
      .returns(T.nilable(T.any(Proposal::PrivateRelation, Proposal::PrivateAssociationRelation)))
  end
  def self.search_by_code(terms)
    matched_code = match_code(terms)
    results = where(id: matched_code[1]) if matched_code
    results if results.present? && T.must(results.first).code == terms
  end

  sig { params(terms: String).returns(T.nilable(MatchData)) }
  def self.match_code(terms)
    /\A#{Setting["proposal_code_prefix"]}-\d\d\d\d-\d\d-(\d*)\z/.match(terms)
  end

  sig { returns(T::Hash[String, T.any(Proposal::PrivateRelation, Proposal::PrivateAssociationRelation)]) }
  def self.for_summary
    summary = {}
    categories = Tag.category_names.sort
    geozones   = Geozone.names.sort

    groups = categories + geozones
    groups.each do |group|
      summary[group] = search(T.must(group)).last_week.sort_by_confidence_score.limit(3)
    end
    summary
  end

  sig { returns(T.nilable(Integer)) }
  def total_votes
    cached_votes_up
  end

  sig { returns(User::PrivateRelation) }
  def voters
    User.active.where(id: votes_for.voters)
  end

  sig { returns(T::Boolean) }
  def editable?
    T.must(total_votes) <= Setting["max_votes_for_proposal_edit"].to_i
  end

  sig { params(user: User).returns(T::Boolean) }
  def editable_by?(user)
    author_id == user.id && editable?
  end

  sig { params(user: T.nilable(User)).returns(T.nilable(T::Boolean)) }
  def votable_by?(user)
    user&.level_two_or_three_verified?
  end

  sig { returns(T::Boolean) }
  def retired?
    retired_at.present?
  end

  sig { params(user: T.nilable(User), vote_value: T.any(String, T::Boolean)).void }
  def register_vote(user, vote_value)
    if user && votable_by?(user) && !archived?
      user.with_lock { vote_by(voter: user, vote: vote_value) }
    end
  end

  sig { returns(String) }
  def code
    "#{Setting["proposal_code_prefix"]}-#{created_at.strftime("%Y-%m")}-#{id}"
  end

  sig { returns(T::Boolean) }
  def after_commented
    save # update cache when it has a new comment
  end

  sig { void }
  def calculate_hot_score
    self.hot_score = ScoreCalculator.hot_score(self)
  end

  sig { void }
  def calculate_confidence_score
    total_votes = T.must(self.total_votes)
    self.confidence_score = ScoreCalculator.confidence_score(total_votes, total_votes).to_i
  end

  sig { void }
  def after_hide
    tags.each { |t| t.decrement_custom_counter_for("Proposal") }
  end

  sig { void }
  def after_restore
    tags.each { |t| t.increment_custom_counter_for("Proposal") }
  end

  sig { returns(Integer) }
  def self.votes_needed_for_success
    Setting["votes_for_proposal_success"].to_i
  end

  sig { returns(T::Boolean) }
  def successful?
    T.must(total_votes) >= Proposal.votes_needed_for_success
  end

  sig { returns(T::Boolean) }
  def archived?
    created_at <= Setting.archived_proposals_date_limit
  end

  sig { returns(ProposalNotification::PrivateCollectionProxy) }
  def notifications
    proposal_notifications
  end

  sig { returns(T::Array[User]) }
  def users_to_notify
    followers - [author]
  end

  sig { params(notification: ProposalNotification).void }
  def notify_users(notification)
    users_to_notify.each do |user|
      Notification.add(user, notification)
    end
  end

  sig { params(user: T.nilable(User)).returns(T::Array[String]) }
  def self.proposals_orders(user)
    orders = %w[hot_score confidence_score created_at relevance archival_date]

    if Setting["feature.user.recommendations_on_proposals"] && user&.recommended_proposals
      orders << "recommendations"
    end

    orders
  end

  sig { returns(T::Boolean) }
  def skip_user_verification?
    Setting["feature.user.skip_verification"].present?
  end

  sig { void }
  def send_new_actions_notification_on_create
    new_actions = Dashboard::Action.detect_new_actions_since(Date.yesterday, self)

    if new_actions.present?
      Dashboard::Mailer.delay.new_actions_notification_on_create(self)
    end
  end

  sig { void }
  def send_new_actions_notification_on_published
    new_actions_ids = Dashboard::Action.detect_new_actions_since(Date.yesterday, self)

    if new_actions_ids.present?
      Dashboard::Mailer.delay.new_actions_notification_on_published(self, new_actions_ids)
    end
  end

  protected

    sig { void }
    def set_responsible_name
      author = self.author
      if author&.document_number?
        self.responsible_name = author.document_number
      end
    end
end
