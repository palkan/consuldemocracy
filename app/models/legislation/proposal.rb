# typed: strict
class Legislation::Proposal < ApplicationRecord
  include ActsAsParanoidAliases
  include Flaggable
  include Taggable
  include Conflictable
  include Measurable
  include Searchable
  include Filterable
  include Followable
  include Communitable
  include Documentable
  include Videoable
  include Notifiable
  include Imageable
  include Randomizable
  include SDG::Relatable

  accepts_nested_attributes_for :documents, allow_destroy: true

  acts_as_votable
  acts_as_paranoid column: :hidden_at

  belongs_to :process, foreign_key: "legislation_process_id", inverse_of: :proposals
  belongs_to :author, -> { with_hidden }, class_name: "User", inverse_of: :legislation_proposals
  belongs_to :geozone
  has_many :comments, as: :commentable, inverse_of: :commentable

  validates :title, presence: true
  validates :summary, presence: true
  validates :author, presence: true
  validates :process, presence: true

  validates :title, length: { in: 4..Legislation::Proposal.title_max_length }
  validates :description, length: { maximum: Legislation::Proposal.description_max_length }

  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  before_validation :set_responsible_name

  before_save :calculate_hot_score, :calculate_confidence_score

  scope :sort_by_confidence_score, -> { reorder(confidence_score: :desc) }
  scope :sort_by_created_at,       -> { reorder(created_at: :desc) }
  scope :sort_by_title,            -> { reorder(title: :asc) }
  scope :sort_by_id,               -> { reorder(id: :asc) }
  scope :sort_by_supports,         -> { reorder(cached_votes_score: :desc) }
  scope :sort_by_flags,            -> { order(flags_count: :desc, updated_at: :desc) }
  scope :last_week,                -> { where(created_at: 7.days.ago..) }
  scope :selected,                 -> { where(selected: true) }
  scope :winners,                  -> { selected.sort_by_confidence_score }

  sig { returns(String) }
  def to_param
    "#{id}-#{title}".parameterize
  end

  sig { returns(T::Hash[T.nilable(String), String]) }
  def searchable_values
    { title => "A",
      T.must(author).username => "B",
      tag_list.join(" ") => "B",
      geozone&.name => "B",
      summary => "C",
      description => "D" }
  end

  sig do
    params(terms: String)
      .returns(
        T.any(Legislation::Proposal::PrivateRelation, Legislation::Proposal::PrivateAssociationRelation)
      )
  end
  def self.search(terms)
    by_code = search_by_code(terms.strip)
    by_code.presence || pg_search(terms)
  end

  sig do
    params(terms: String)
      .returns(
        T.nilable(
          T.any(Legislation::Proposal::PrivateRelation, Legislation::Proposal::PrivateAssociationRelation)
        )
      )
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

  sig { returns(T.nilable(Integer)) }
  def likes
    cached_votes_up
  end

  sig { returns(T.nilable(Integer)) }
  def dislikes
    cached_votes_down
  end

  sig { returns(T.nilable(Integer)) }
  def total_votes
    cached_votes_total
  end

  sig { returns(T.nilable(Integer)) }
  def votes_score
    cached_votes_score
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
    tags.each { |t| t.decrement_custom_counter_for("LegislationProposal") }
  end

  sig { void }
  def after_restore
    tags.each { |t| t.increment_custom_counter_for("LegislationProposal") }
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
