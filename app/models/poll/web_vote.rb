# typed: strict
class Poll::WebVote
  include ActiveModel::Validations
  extend T::Sig

  Answers = T.type_alias do
    T::Hash[Integer, T.any(Poll::Answer::PrivateAssociationRelation, T::Array[Poll::Answer])]
  end

  Params = T.type_alias { T.any(ActionController::Parameters, T::Hash[T.untyped, T.untyped]) }

  sig { returns(Poll) }
  attr_reader :poll

  sig { returns(T.nilable(User)) }
  attr_reader :user

  delegate :t, to: "ApplicationController.helpers"

  validate :max_answers

  sig { params(poll: Poll, user: T.nilable(User)).void }
  def initialize(poll, user)
    @poll = poll
    @user = user
    @answers = T.let(nil, T.nilable(Answers))
  end

  sig { returns(Poll::Question::PrivateAssociationRelation) }
  def questions
    poll.questions.for_render.sort_for_list
  end

  sig { returns(Answers) }
  def answers
    @answers ||= questions.to_h do |question|
      [question.id, question.answers.where(author: user)]
    end
  end

  sig { params(params: Params).returns(T::Boolean) }
  def update(params)
    all_valid = T.let(true, T::Boolean)

    T.must(user).with_lock do
      self.answers = given_answers(params)

      questions.each do |question|
        question_answers = T.must(answers[question.id])
        question.answers.where(author: user).where.not(id: question_answers.map(&:id)).destroy_all

        if valid? && question_answers.all?(&:valid?)
          Poll::Voter.find_or_create_by!(user: user, poll: poll, origin: "web")
          question_answers.each(&:save!)
        else
          all_valid = false
        end
      end

      raise ActiveRecord::Rollback unless all_valid
    end

    all_valid
  end

  sig { returns(NilClass) }
  def to_key
  end

  sig { returns(T::Boolean) }
  def persisted?
    Poll::Voter.where(user: user, poll: poll, origin: "web").exists?
  end

  private

    sig { params(answers: Answers).returns(Answers) }
    attr_writer :answers

    sig { params(params: Params).returns(T::Hash[Integer, T::Array[Poll::Answer]]) }
    def given_answers(params)
      questions.to_h do |question|
        [question.id, answers_for_question(question, params[question.id.to_s])]
      end
    end

    sig { params(question: Poll::Question, question_params: T.untyped).returns(T::Array[Poll::Answer]) }
    def answers_for_question(question, question_params)
      return [] unless question_params

      answer_param = question_params[:answer]
      if question.open?
        answer_text = answer_param.to_s.strip
        if answer_text.present?
          [question.find_or_initialize_user_answer(T.must(user), answer_text: answer_text)]
        else
          []
        end
      else
        Array(question_params[:option_id]).map do |option_id|
          option_answer_text = answer_param&.dig(option_id).to_s.strip
          question.find_or_initialize_user_answer(T.must(user),
                                                  option_id: option_id,
                                                  answer_text: option_answer_text)
        end
      end
    end

    sig { void }
    def max_answers
      questions.each do |question|
        question_answers = T.must(answers[question.id])

        if question_answers.count > question.max_votes
          errors.add(
            :"question_#{question.id}",
            t("polls.form.maximum_exceeded", maximum: question.max_votes, given: question_answers.count)
          )
        end
      end
    end
end
