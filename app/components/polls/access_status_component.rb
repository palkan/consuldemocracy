# typed: strict
class Polls::AccessStatusComponent < ApplicationComponent
  sig { returns(Poll) }
  attr_reader :poll

  sig { params(poll: Poll).void }
  def initialize(poll)
    @poll = poll
  end

  sig { returns(T::Boolean) }
  def render?
    attributes.present?
  end

  private

    sig { returns(T.nilable(String)) }
    def text
      T.must(attributes)[:text]
    end

    sig { returns(T.nilable(String)) }
    def html_class
      T.must(attributes)[:class]
    end

    sig { returns(T.nilable(T::Hash[Symbol, String])) }
    def attributes
      if (user = current_user)
        if user.unverified?
          { text: t("polls.index.unverified"), class: "unverified" }
        elsif cannot?(:answer, poll)
          { text: t("polls.index.cant_answer"), class: "cant-answer" }
        elsif !poll.votable_by?(user)
          { text: t("polls.index.already_answer"), class: "already-answer" }
        end
      else
        { text: t("polls.index.not_logged_in"), class: "not-logged-in" }
      end
    end
end
