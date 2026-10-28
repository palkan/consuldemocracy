# typed: strict
class Notification < ApplicationRecord
  belongs_to :user, counter_cache: true
  belongs_to :notifiable, polymorphic: true

  validates :user, presence: true

  scope :read,        -> { where.not(read_at: nil).recent.for_render }
  scope :unread,      -> { where(read_at: nil).recent.for_render }
  scope :not_emailed, -> { where(emailed_at: nil) }
  scope :recent,      -> { order(id: :desc) }
  scope :for_render,  -> { includes(:notifiable) }

  delegate :notifiable_title, :notifiable_body, :notifiable_available?, :linkable_resource,
           to: :notifiable, allow_nil: true

  sig { returns(T::Boolean) }
  def mark_as_read
    update(read_at: Time.current)
  end

  sig { returns(T::Boolean) }
  def mark_as_unread
    update(read_at: nil)
  end

  sig { returns(T::Boolean) }
  def read?
    read_at.present?
  end

  sig { returns(T::Boolean) }
  def unread?
    read_at.nil?
  end

  sig { returns(ActiveSupport::TimeWithZone) }
  def timestamp
    notifiable.created_at
  end

  sig { params(user: User, notifiable: ActiveRecord::Base).returns(T.any(Integer, Notification)) }
  def self.add(user, notifiable)
    notification = Notification.existent(user, notifiable)
    if notification.present?
      increment_counter(:counter, notification.id)
    else
      create!(user: user, notifiable: notifiable)
    end
  end

  sig { params(user: User, notifiable: ActiveRecord::Base).returns(T.nilable(Notification)) }
  def self.existent(user, notifiable)
    unread.find_by(user: user, notifiable: notifiable)
  end

  sig { returns(T.nilable(String)) }
  def notifiable_action
    case notifiable_type
    when "ProposalNotification"
      "proposal_notification"
    when "Comment"
      "replies_to"
    when "AdminNotification"
      nil
    else
      "comments_on"
    end
  end

  sig { returns(T.nilable(Notification)) }
  def link
    if notifiable.is_a?(AdminNotification) && notifiable.link.blank?
      nil
    else
      self
    end
  end

  sig { void }
  def self.send_pending
    run_at = T.let(first_batch_run_at, ActiveSupport::TimeWithZone)
    User.email_digest.find_in_batches(batch_size: batch_size) do |users|
      users.each do |user|
        email_digest = EmailDigest.new(user)
        email_digest.deliver(run_at)
      end
      run_at += batch_interval
    end
  end

  private

    sig { returns(Integer) }
    def self.batch_size
      10000
    end

    sig { returns(ActiveSupport::Duration) }
    def self.batch_interval
      20.minutes
    end

    sig { returns(ActiveSupport::TimeWithZone) }
    def self.first_batch_run_at
      Time.current
    end
end
