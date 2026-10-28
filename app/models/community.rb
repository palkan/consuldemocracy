# typed: strict
class Community < ApplicationRecord
  has_one :proposal
  has_one :investment, class_name: "Budget::Investment"
  has_many :topics

  sig { returns(T::Array[User]) }
  def participants
    users_participants = users_who_commented +
                         users_who_topics_author +
                         author_from_community
    users_participants.uniq
  end

  sig { returns(T::Boolean) }
  def from_proposal?
    proposal.present?
  end

  sig { returns(T.nilable(ActiveSupport::TimeWithZone)) }
  def latest_activity
    activity = T.let([], T::Array[T.nilable(ActiveSupport::TimeWithZone)])

    most_recent_comment = Comment.where(commentable: topics).order(updated_at: :desc).take(1).first
    activity << most_recent_comment.updated_at unless most_recent_comment.nil?

    most_recent_topic = topics.order(updated_at: :desc).take(1).first
    activity << most_recent_topic.updated_at unless most_recent_topic.nil?

    activity.max
  end

  sig { returns(Integer) }
  def comments_count
    comments.count
  end

  sig { returns(Comment::PrivateRelation) }
  def comments
    Comment.where(commentable: topics)
  end

  sig { returns(Integer) }
  def debates_count
    topics.count
  end

  sig { returns(Integer) }
  def participants_count
    participants.count
  end

  private

    sig { returns(User::PrivateRelation) }
    def users_who_commented
      User.by_comments(topics)
    end

    sig { returns(User::PrivateRelation) }
    def users_who_topics_author
      ids = topics.pluck(:author_id)
      User.with_ids(ids)
    end

    sig { returns(User::PrivateRelation) }
    def author_from_community
      from_proposal? ? User.where(id: proposal&.author_id) : User.where(id: investment&.author_id)
    end
end
