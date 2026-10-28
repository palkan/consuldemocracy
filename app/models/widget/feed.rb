# typed: strict
class Widget::Feed < ApplicationRecord
  KINDS = %w[proposals debates processes].freeze

  sig { returns(T::Boolean) }
  def active?
    T.must(setting).value.present?
  end

  sig { returns(T.nilable(Setting)) }
  def setting
    Setting.find_by(key: "homepage.widgets.feeds.#{kind}")
  end

  sig { returns(T::Array[Widget::Feed]) }
  def self.active
    KINDS.map do |kind|
      feed = find_or_create_by!(kind: kind)
      feed if feed.active?
    end.compact
  end

  sig do
    returns(T.any(Proposal::PrivateRelation, Debate::PrivateRelation, Legislation::Process::PrivateRelation))
  end
  def items
    send(T.must(kind))
  end

  sig { returns(Proposal::PrivateRelation) }
  def proposals
    Proposal.published.sort_by_hot_score.limit(limit)
  end

  sig { returns(Debate::PrivateRelation) }
  def debates
    Debate.sort_by_hot_score.limit(limit)
  end

  sig { returns(Legislation::Process::PrivateRelation) }
  def processes
    Legislation::Process.open.published.order(created_at: :desc).limit(limit)
  end
end
