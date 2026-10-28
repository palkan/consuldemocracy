# typed: strict
class Poll::Question < ApplicationRecord
  include Measurable

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  translates :title, touch: true
  include Globalizable

  belongs_to :poll
  belongs_to :author, -> { with_hidden }, class_name: "User", inverse_of: :poll_questions

  has_many :comments, as: :commentable, inverse_of: :commentable
  has_many :answers, class_name: "Poll::Answer"
  has_many :question_options, -> { order :given_order },
           class_name: "Poll::Question::Option",
           inverse_of: :question,
           dependent: :destroy
  has_many :partial_results
  has_one :votation_type, as: :questionable, dependent: :destroy
  belongs_to :proposal

  validates_translation :title, presence: true, length: { minimum: 4 }
  validates :author, presence: true
  validates :poll_id, presence: true, if: proc { |question| question.poll.nil? }

  accepts_nested_attributes_for :question_options, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :votation_type

  delegate :multiple?, :open?, :vote_type, to: :votation_type, allow_nil: true

  scope :sort_for_list, -> { order(Arel.sql("poll_questions.proposal_id IS NULL"), :created_at) }
  scope :for_render,    -> { includes(:author, :proposal) }
  scope :for_physical_votes, -> { left_joins(:votation_type).merge(VotationType.accepts_options) }

  sig { params(proposal: T.nilable(Proposal)).void }
  def copy_attributes_from_proposal(proposal)
    if proposal.present?
      self.author = proposal.author
      self.author_visible_name = T.must(proposal.author).name
      self.proposal_id = proposal.id
      send(:"#{localized_attr_name_for(:title, Globalize.locale)}=", proposal.title)
    end
  end

  sig { returns(Integer) }
  def options_total_votes
    question_options.reduce(0) { |total, question_option| total + question_option.total_votes }
  end

  sig { returns(T.nilable(Integer)) }
  def most_voted_option_id
    question_options.max_by(&:total_votes)&.id
  end

  sig { returns(T::Boolean) }
  def options_with_read_more?
    options_with_read_more.any?
  end

  sig { returns(T::Array[Poll::Question::Option]) }
  def options_with_read_more
    question_options.select(&:with_read_more?)
  end

  sig { returns(T::Boolean) }
  def unique?
    votation_type = self.votation_type
    votation_type.nil? || votation_type.unique?
  end

  sig { returns(T::Boolean) }
  def accepts_options?
    votation_type = self.votation_type
    votation_type.nil? || votation_type.accepts_options?
  end

  sig { params(title: String).returns(T.nilable(Poll::Question::Option)) }
  def option_for(title)
    question_options.find_by(title: title)
  end

  sig { returns(Integer) }
  def max_votes
    if multiple?
      T.must(T.must(votation_type).max_votes)
    else
      1
    end
  end

  sig do
    params(user: User, option_id: T.nilable(T.any(Integer, String)), answer_text: T.nilable(String))
      .returns(Poll::Answer)
  end
  def find_or_initialize_user_answer(user, option_id: nil, answer_text: nil)
    answer = answers.find_or_initialize_by(find_by_attributes(user, option_id))

    if accepts_options?
      answer.option = question_options.find(T.unsafe(option_id))
      answer.answer = answer_text.presence if T.must(answer.option).allow_custom_text?
    else
      answer.option = nil
      answer.answer = answer_text
    end

    answer
  end

  sig { returns(Integer) }
  def open_ended_valid_answers_count
    answers.count
  end

  sig { returns(Integer) }
  def open_ended_blank_answers_count
    T.must(poll).voters.count - open_ended_valid_answers_count
  end

  sig { returns(Float) }
  def open_ended_valid_percentage
    return 0.0 if open_ended_total_answers.zero?

    (open_ended_valid_answers_count * 100.0) / open_ended_total_answers
  end

  sig { returns(Float) }
  def open_ended_blank_percentage
    return 0.0 if open_ended_total_answers.zero?

    (open_ended_blank_answers_count * 100.0) / open_ended_total_answers
  end

  private

    sig do
      params(user: User, option_id: T.nilable(T.any(Integer, String))).returns(T::Hash[Symbol, T.untyped])
    end
    def find_by_attributes(user, option_id)
      if multiple?
        { author: user, option_id: option_id }
      else
        { author: user }
      end
    end

    sig { returns(Integer) }
    def open_ended_total_answers
      open_ended_valid_answers_count + open_ended_blank_answers_count
    end
end
