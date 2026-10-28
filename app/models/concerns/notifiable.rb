# typed: strict
module Notifiable
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ApplicationRecord }

  sig { returns(T.nilable(String)) }
  def notifiable_title
    case self.class.name
    when "ProposalNotification"
      T.must(T.cast(self, ProposalNotification).proposal).title
    when "Comment"
      T.cast(self, Comment).commentable.title
    else
      title
    end
  end

  sig { returns(T.nilable(String)) }
  def notifiable_body
    public_send(:body) if attribute_names.include?("body")
  end

  sig { returns(T::Boolean) }
  def notifiable_available?
    notifiable_resource.present? &&
      !(notifiable_resource.respond_to?(:hidden?) && notifiable_resource.hidden?) &&
      !(notifiable_resource.respond_to?(:retired?) && notifiable_resource.retired?)
  end

  sig { returns(T.untyped) }
  def notifiable_resource
    case self.class.name
    when "ProposalNotification"
      T.cast(self, ProposalNotification).proposal
    when "Comment"
      T.cast(self, Comment).commentable
    else
      self
    end
  end

  sig { returns(T.nilable(Notifiable)) }
  def linkable_resource
    is_a?(ProposalNotification) ? proposal : self
  end
end
