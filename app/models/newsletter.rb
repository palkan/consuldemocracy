# typed: strict
class Newsletter < ApplicationRecord
  has_many :activities, as: :actionable, inverse_of: :actionable

  validates :subject, presence: true
  validates :segment_recipient, presence: true
  validates :from, presence: true, format: { with: /\A.+@.+\Z/ }
  validates :body, presence: true
  validate :validate_segment_recipient

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  sig { returns(T::Array[String]) }
  def list_of_recipient_emails
    UserSegments.user_segment_emails(segment_recipient)
  end

  sig { returns(T::Boolean) }
  def valid_segment_recipient?
    UserSegments.valid_segment?(segment_recipient)
  end

  sig { returns(T::Boolean) }
  def draft?
    sent_at.nil?
  end

  sig { void }
  def deliver
    run_at = T.let(first_batch_run_at, ActiveSupport::TimeWithZone)
    list_of_recipient_emails_in_batches.each do |recipient_emails|
      recipient_emails.each do |recipient_email|
        if valid_email?(recipient_email)
          Mailer.delay(run_at: run_at).newsletter(self, recipient_email)
          log_delivery(recipient_email)
        end
      end
      run_at += batch_interval
    end
  end

  sig { returns(Integer) }
  def batch_size
    10000
  end

  sig { returns(ActiveSupport::Duration) }
  def batch_interval
    20.minutes
  end

  sig { returns(ActiveSupport::TimeWithZone) }
  def first_batch_run_at
    Time.current
  end

  sig { returns(T::Array[T::Array[String]]) }
  def list_of_recipient_emails_in_batches
    T.cast(list_of_recipient_emails.in_groups_of(batch_size, false), T::Array[T::Array[String]])
  end

  private

    sig { void }
    def validate_segment_recipient
      errors.add(:segment_recipient, :invalid) unless valid_segment_recipient?
    end

    sig { params(email: String).returns(T.nilable(MatchData)) }
    def valid_email?(email)
      email.match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i)
    end

    sig { params(recipient_email: String).void }
    def log_delivery(recipient_email)
      user = User.find_by(email: recipient_email)
      Activity.log(user, :email, self)
    end
end
