# typed: strict
class EmailDigest
  extend T::Sig

  sig { returns(User) }
  attr_accessor :user

  sig { params(user: User).void }
  def initialize(user)
    @user = user
  end

  sig { returns(Notification::PrivateAssociationRelation) }
  def notifications
    user.notifications.not_emailed.where(notifiable_type: "ProposalNotification")
  end

  sig { returns(T::Boolean) }
  def pending_notifications?
    notifications.any?
  end

  sig { params(run_at: T.any(Time, ActiveSupport::TimeWithZone)).void }
  def deliver(run_at)
    if valid_email? && pending_notifications?
      Mailer.delay(run_at: run_at).proposal_notification_digest(user, notifications.to_a)
      mark_as_emailed
    end
  end

  sig { void }
  def mark_as_emailed
    notifications.update_all(emailed_at: Time.current)
    user.update!(failed_email_digests_count: 0)
  end

  sig { returns(T.nilable(T.any(MatchData, FalseClass))) }
  def valid_email?
    email = user.email
    email.present? && email.match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i)
  end
end
