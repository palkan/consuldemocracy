# typed: true
class User < ApplicationRecord
  include Verification

  attribute :registering_from_web, default: false
  %i[newsletter email_digest email_on_direct_message public_activity recommended_debates
     recommended_proposals].each do |field|
    attribute field, :boolean, default: -> { !Setting["feature.gdpr.require_consent_for_notifications"] }
  end

  devise :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable,
         :trackable, :validatable, :omniauthable, :password_expirable, :secure_validatable,
         authentication_keys: [:login]
  devise :lockable if Rails.application.config.devise_lockable

  acts_as_voter
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  include Graphqlable

  has_one :administrator
  has_one :moderator
  has_one :valuator
  has_one :manager
  has_one :sdg_manager, class_name: "SDG::Manager", dependent: :destroy
  has_one :poll_officer, class_name: "Poll::Officer"
  has_one :organization
  has_one :lock
  has_many :flags
  has_many :identities, dependent: :destroy
  has_many :debates, -> { with_hidden }, foreign_key: :author_id, inverse_of: :author
  has_many :proposals, -> { with_hidden }, foreign_key: :author_id, inverse_of: :author
  has_many :proposal_notifications, -> { with_hidden },
           foreign_key: :author_id,
           inverse_of: :author
  has_many :activities
  has_many :budget_investments, -> { with_hidden },
           class_name: "Budget::Investment",
           foreign_key: :author_id,
           inverse_of: :author
  has_many :comments, -> { with_hidden }, inverse_of: :user
  has_many :failed_census_calls
  has_many :notifications
  has_many :direct_messages_sent,
           class_name: "DirectMessage",
           foreign_key: :sender_id,
           inverse_of: :sender
  has_many :direct_messages_received,
           class_name: "DirectMessage",
           foreign_key: :receiver_id,
           inverse_of: :receiver
  has_many :legislation_answers, class_name: "Legislation::Answer", dependent: :destroy, inverse_of: :user
  has_many :follows
  has_many :legislation_annotations,
           class_name: "Legislation::Annotation",
           foreign_key: :author_id,
           inverse_of: :author
  has_many :legislation_proposals,
           class_name: "Legislation::Proposal",
           foreign_key: :author_id,
           inverse_of: :author
  has_many :legislation_questions,
           class_name: "Legislation::Question",
           foreign_key: :author_id,
           inverse_of: :author
  has_many :polls, foreign_key: :author_id, inverse_of: :author
  has_many :poll_answers,
           class_name: "Poll::Answer",
           foreign_key: :author_id,
           inverse_of: :author
  has_many :poll_partial_results,
           class_name: "Poll::PartialResult",
           foreign_key: :author_id,
           inverse_of: :author
  has_many :poll_questions,
           class_name: "Poll::Question",
           foreign_key: :author_id,
           inverse_of: :author
  has_many :poll_recounts,
           class_name: "Poll::Recount",
           foreign_key: :author_id,
           inverse_of: :author
  has_many :related_contents, foreign_key: :author_id, inverse_of: :author, dependent: nil
  has_many :topics, foreign_key: :author_id, inverse_of: :author
  belongs_to :geozone

  validates :username, presence: true, if: :username_required?
  validates :username, uniqueness: { scope: :registering_with_oauth }, if: :username_required?
  validates :document_number, uniqueness: { scope: :document_type }, allow_nil: true

  validate :validate_username_length

  validates :official_level, inclusion: { in: 0..5 }
  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  validates_associated :organization, message: false

  normalizes :document_number, with: ->(document_number) { document_number.gsub(/[^a-z0-9]+/i, "").upcase }

  accepts_nested_attributes_for :organization, update_only: true

  attr_accessor :skip_password_validation, :login

  scope :administrators, -> { joins(:administrator) }
  scope :moderators,     -> { joins(:moderator) }
  scope :organizations,  -> { joins(:organization) }
  scope :sdg_managers,   -> { joins(:sdg_manager) }
  scope :officials,      -> { where(official_level: 1..) }
  scope :male,           -> { where(gender: "male") }
  scope :female,         -> { where(gender: "female") }
  scope :newsletter,     -> { where(newsletter: true) }
  scope :for_render,     -> { includes(:organization) }
  scope :by_document,    ->(document_type, document_number) do
    where(document_type: document_type, document_number: document_number)
  end
  scope :email_digest,   -> { where(email_digest: true) }
  scope :active,         -> { where(erased_at: nil) }
  scope :erased,         -> { where.not(erased_at: nil) }
  scope :public_for_api, -> { all }
  scope :with_ids,       ->(ids) { where(id: ids) }
  scope :by_comments,    ->(commentables) do
    joins(:comments).where("comments.commentable": commentables).distinct
  end
  scope :by_username_email_or_document_number, ->(search_string) do
    search = "%#{search_string.strip}%"
    where("username ILIKE ? OR email ILIKE ? OR document_number ILIKE ?", search, search, search)
  end
  scope :between_ages, ->(from, to, at_time: Time.current) do
    start_date = at_time - (to + 1).years + 1.day
    end_date = at_time - from.years

    where(date_of_birth: start_date.beginning_of_day..end_date.end_of_day)
  end

  # Get the existing user by email if the provider gives us a verified email.
  sig { params(auth: OmniAuth::AuthHash).returns(User) }
  def self.first_or_initialize_for_oauth(auth)
    oauth_email           = auth.info.email
    oauth_verified        = auth.info.verified || auth.info.verified_email || auth.info.email_verified
    oauth_email_confirmed = oauth_email.present? && oauth_verified
    oauth_user            = User.find_by(email: oauth_email) if oauth_email_confirmed

    oauth_user || User.new(
      username: auth.info.name || auth.uid,
      email: oauth_email,
      oauth_email: oauth_email,
      password: Devise.friendly_token[0, 20],
      terms_of_service: "1",
      confirmed_at: oauth_email_confirmed ? DateTime.current : nil
    )
  end

  sig do
    params(
      response: T.any(CensusApi::Response, RemoteCensusApi::Response, LocalCensus::Response),
      params: T::Hash[T.untyped, T.untyped]
    ).returns(User)
  end
  def self.create_from_census_response!(response, params = {})
    create!({
      verified_at: Time.current,
      erased_at: Time.current,
      password: random_password,
      terms_of_service: "1",
      email: nil,
      gender: response.gender,
      date_of_birth: T.must(response.date_of_birth).in_time_zone.to_datetime,
      geozone: Geozone.find_by(census_code: response.district_code)
    }.merge(params))
  end

  sig { returns(T.nilable(String)) }
  def name
    organization? ? T.must(organization).name : username
  end

  sig { params(group: Budget::Group).returns(T::Boolean) }
  def voted_in_group?(group)
    votes.where(votable: Budget::Investment.where(group: group)).exists?
  end

  sig { params(group: Budget::Group).returns(Budget::Heading::PrivateRelation) }
  def headings_voted_within_group(group)
    Budget::Heading.where(id: voted_investments.by_group(group).pluck(:heading_id))
  end

  sig { returns(Budget::Investment::PrivateRelation) }
  def voted_investments
    Budget::Investment.where(id: votes.where(votable: Budget::Investment.all).pluck(:votable_id))
  end

  sig { returns(T::Boolean) }
  def administrator?
    administrator.present?
  end

  sig { returns(T::Boolean) }
  def moderator?
    moderator.present?
  end

  sig { returns(T::Boolean) }
  def valuator?
    valuator.present?
  end

  sig { returns(T::Boolean) }
  def manager?
    manager.present?
  end

  sig { returns(T::Boolean) }
  def sdg_manager?
    sdg_manager.present?
  end

  sig { returns(T::Boolean) }
  def poll_officer?
    poll_officer.present?
  end

  sig { returns(T::Boolean) }
  def organization?
    organization.present?
  end

  sig { returns(T.nilable(T::Boolean)) }
  def verified_organization?
    organization&.verified?
  end

  sig { returns(T.nilable(T::Boolean)) }
  def official?
    level = official_level
    level && level > 0
  end

  sig { params(position: T.nilable(String), level: T.nilable(T.any(Integer, String))).void }
  def add_official_position!(position, level)
    return if position.blank? || level.blank?

    update! official_position: position, official_level: level.to_i
  end

  sig { void }
  def remove_official_position!
    update! official_position: nil, official_level: 0
  end

  sig { returns(T::Boolean) }
  def has_official_email?
    domain = Setting["email_domain_for_officials"]
    user_email = email.to_s
    user_email.present? && ((user_email.end_with? "@#{domain}") || (user_email.end_with? ".#{domain}"))
  end

  sig { returns(T::Boolean) }
  def display_official_position_badge?
    return true if T.must(official_level) > 1

    official_position_badge? && official_level == 1
  end

  sig { void }
  def block
    hide

    Debate.hide_all debate_ids
    Comment.hide_all comment_ids
    Legislation::Proposal.hide_all legislation_proposal_ids
    Proposal.hide_all proposal_ids
    Budget::Investment.hide_all budget_investment_ids
    ProposalNotification.hide_all ProposalNotification.where(author_id: id).ids
    remove_roles
  end

  sig { void }
  def full_restore
    ActiveRecord::Base.transaction do
      Debate.restore_all debates.where(hidden_at: hidden_at..)
      Comment.restore_all comments.where(hidden_at: hidden_at..)
      Legislation::Proposal.restore_all(
        Legislation::Proposal.only_hidden.where(author_id: id, hidden_at: hidden_at..)
      )
      Proposal.restore_all proposals.where(hidden_at: hidden_at..)
      Budget::Investment.restore_all budget_investments.where(hidden_at: hidden_at..)
      ProposalNotification.restore_all(
        ProposalNotification.only_hidden.where(hidden_at: hidden_at..).where(author_id: id)
      )

      restore
    end
  end

  sig { params(erase_reason: T.nilable(String)).void }
  def erase(erase_reason = nil)
    update!(
      erased_at: Time.current,
      erase_reason: erase_reason,
      username: nil,
      email: nil,
      unconfirmed_email: nil,
      phone_number: nil,
      encrypted_password: "",
      confirmation_token: nil,
      reset_password_token: nil,
      email_verification_token: nil,
      confirmed_phone: nil,
      unconfirmed_phone: nil
    )
    identities.destroy_all
    remove_roles
  end

  sig { returns(T::Boolean) }
  def erased?
    erased_at.present?
  end

  sig { void }
  def remove_roles
    administrator&.destroy!
    valuator&.destroy!
    moderator&.destroy!
    manager&.destroy!
    sdg_manager&.destroy!
  end

  sig do
    params(
      document_number: T.nilable(T.any(String, Integer)),
      document_type: T.nilable(T.any(String, Integer))
    ).void
  end
  def take_votes_if_erased_document(document_number, document_type)
    erased_user = User.erased.find_by(document_number: document_number,
                                      document_type: document_type)
    if erased_user.present?
      take_votes_from(erased_user)
      erased_user.update!(document_number: nil, document_type: nil)
    end
  end

  sig { params(other_user: T.nilable(User)).void }
  def take_votes_from(other_user)
    return if other_user.blank?

    Poll::Voter.where(user_id: other_user.id).find_each do |poll_voter|
      transaction(requires_new: true) { poll_voter.update_column(:user_id, id) }
    rescue ActiveRecord::RecordNotUnique
      poll_voter.delete
    end

    Budget::Ballot.where(user_id: other_user.id).update_all(user_id: id)

    with_lock do
      Vote.where(voter_id: other_user.id, voter_type: "User").find_each do |vote|
        votable = vote.votable
        if Vote.where(voter_id: id, voter_type: "User", votable: votable).any?
          vote.delete
          votable&.update_cached_votes
        else
          vote.update_column(:voter_id, id)
        end
      end
    end

    data_log = "id: #{other_user.id} - #{Time.current.strftime("%Y-%m-%d %H:%M:%S")}"
    update!(former_users_data_log: "#{former_users_data_log} | #{data_log}")
  end

  sig { returns(T::Boolean) }
  def locked?
    Lock.find_or_create_by!(user: self).locked?
  end

  sig { params(term: T.nilable(String)).returns(User::PrivateRelation) }
  def self.search(term)
    return none if term.blank?

    search = term.strip
    where("email = ? OR username ILIKE ?", search, "%#{search}%")
  end

  sig { returns(Integer) }
  def self.username_max_length
    @username_max_length ||= columns.find { |c| c.name == "username" }.limit || 60
  end

  sig { returns(Integer) }
  def self.minimum_required_age
    (Setting["min_age_to_participate"] || 16).to_i
  end

  sig { returns(T::Boolean) }
  def show_welcome_screen?
    verification = Setting["feature.user.skip_verification"].present? || unverified?
    sign_in_count == 1 && verification && !organization && !administrator?
  end

  sig { returns(T::Boolean) }
  def password_required?
    return false if skip_password_validation

    super
  end

  sig { returns(T::Boolean) }
  def username_required?
    !organization? && !erased?
  end

  sig { returns(T::Boolean) }
  def email_required?
    !erased? && (unverified? || registering_from_web)
  end

  sig { returns(String) }
  def locale
    self[:locale] || Setting.default_locale.to_s
  end

  sig { returns(T::Boolean) }
  def confirmation_required?
    T.let(super, T::Boolean) && !registering_with_oauth
  end

  sig { void }
  def send_oauth_confirmation_instructions
    if oauth_email != email || confirmed_at.nil?
      update(confirmed_at: nil)
      send_confirmation_instructions
    end
    update(oauth_email: nil) if oauth_email.present?
  end

  sig { returns(String) }
  def name_and_email
    "#{name} (#{email})"
  end

  sig { returns(T.nilable(Integer)) }
  def age
    Age.in_years(date_of_birth)
  end

  sig { returns(TrueClass) }
  def save_requiring_finish_signup
    begin
      self.registering_with_oauth = true
      save!(validate: false)
    # Devise puts unique constraints for the email the db, so we must detect & handle that
    rescue ActiveRecord::RecordNotUnique
      self.email = nil
      save!(validate: false)
    end
    true
  end

  sig { returns(Ability) }
  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, to: :ability

  sig { returns(T.any(Proposal::PrivateCollectionProxy, Proposal::PrivateAssociationRelation)) }
  def public_proposals
    public_activity? ? proposals : proposals.none
  end

  sig { returns(T.any(Debate::PrivateCollectionProxy, Debate::PrivateAssociationRelation)) }
  def public_debates
    public_activity? ? debates : debates.none
  end

  sig { returns(T.any(Comment::PrivateCollectionProxy, Comment::PrivateAssociationRelation)) }
  def public_comments
    public_activity? ? comments : comments.none
  end

  # overwritting of Devise method to allow login using email OR username
  sig { params(warden_conditions: T::Hash[Symbol, T.untyped]).returns(T.nilable(User)) }
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    where(conditions.to_hash).find_by(["lower(email) = ?", login.downcase]) ||
      where(conditions.to_hash).find_by(["username = ?", login])
  end

  sig { returns(T::Array[String]) }
  def interests
    followables = follows.map(&:followable)
    followables.compact.map { |followable| followable.tags.map(&:name) }.flatten.compact.uniq
  end

  sig { params(notification: Symbol, "*": T.untyped).void }
  def send_devise_notification(notification, *)
    devise_mailer.send(notification, self, *).deliver_later
  end

  sig { void }
  def add_subscriptions_token
    update!(subscriptions_token: SecureRandom.base58(32)) if subscriptions_token.blank?
  end

  sig { returns({ digit: Integer, lower: Integer, symbol: Integer, upper: Integer }) }
  def self.password_complexity
    if Tenant.current_secrets.dig(:security, :password_complexity)
      { digit: 1, lower: 1, symbol: 0, upper: 1 }
    else
      { digit: 0, lower: 0, symbol: 0, upper: 0 }
    end
  end

  sig { returns(String) }
  def self.random_password
    lowercase = ("a".."z").to_a
    uppercase = ("A".."Z").to_a
    digits    = ("0".."9").to_a
    symbols   = %w[- _ . , : ; ! @ # $ % & *]
    all_chars = lowercase + uppercase + digits + symbols

    characters = Array.new(password_complexity[:lower]) { lowercase.sample } +
                 Array.new(password_complexity[:upper]) { uppercase.sample } +
                 Array.new(password_complexity[:digit]) { digits.sample } +
                 Array.new(password_complexity[:symbol]) { symbols.sample } +
                 Array.new(password_length.min + rand(2..4)) { all_chars.sample }

    characters.shuffle.join
  end

  sig { returns(Integer) }
  def self.maximum_attempts
    (Tenant.current_secrets.dig(:security, :lockable, :maximum_attempts) || 20).to_i
  end

  sig { returns(ActiveSupport::Duration) }
  def self.unlock_in
    (Tenant.current_secrets.dig(:security, :lockable, :unlock_in) || 1).to_f.hours
  end

  sig { returns(String) }
  def to_param
    "#{id}-#{slug}"
  end

  sig { returns(String) }
  def slug
    username.to_s.parameterize
  end

  private

    sig { void }
    def validate_username_length
      validator = ActiveModel::Validations::LengthValidator.new(
        attributes: :username,
        maximum: User.username_max_length
      )
      validator.validate(self)
    end
end
