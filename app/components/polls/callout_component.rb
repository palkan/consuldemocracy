# typed: strict
class Polls::CalloutComponent < ApplicationComponent
  sig { returns(Poll) }
  attr_reader :poll

  delegate :link_to_signin, :link_to_signup, to: :helpers

  sig { params(poll: Poll).void }
  def initialize(poll)
    @poll = poll
  end

  private

    sig { returns(T::Boolean) }
    def voted_in_booth?
      poll.voted_in_booth?(current_user)
    end

    sig { returns(T::Boolean) }
    def voted_in_web?
      poll.voted_in_web?(current_user)
    end

    sig { returns(T::Boolean) }
    def voted_blank?
      poll.answers.where(author: current_user).none?
    end

    sig { params(text: String, html_class: String).returns(ActiveSupport::SafeBuffer) }
    def callout(text, html_class: "warning")
      tag.div(text, class: "callout #{html_class}")
    end

    sig { returns(T.nilable(ActiveSupport::SafeBuffer)) }
    def not_logged_in_text
      sanitize(t("polls.show.cant_answer_not_logged_in",
                 signin: link_to_signin,
                 signup: link_to_signup))
    end

    sig { returns(T.nilable(ActiveSupport::SafeBuffer)) }
    def unverified_text
      sanitize(t("polls.show.cant_answer_verify",
                 verify_link: link_to(t("polls.show.verify_link"), verification_path)))
    end
end
