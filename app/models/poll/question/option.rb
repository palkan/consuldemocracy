# typed: strict
class Poll::Question::Option < ApplicationRecord
  self.table_name = "poll_question_answers"

  include Galleryable
  include Documentable

  translates :title,       touch: true
  translates :description, touch: true
  include Globalizable

  accepts_nested_attributes_for :documents, allow_destroy: true

  belongs_to :question, class_name: "Poll::Question"
  has_many :answers, class_name: "Poll::Answer", dependent: :nullify
  has_many :partial_results, class_name: "Poll::PartialResult", dependent: :nullify
  has_many :videos, class_name: "Poll::Question::Option::Video",
                    dependent: :destroy,
                    foreign_key: "answer_id",
                    inverse_of: :option

  validates_translation :title, presence: true
  validates :given_order, presence: true, uniqueness: { scope: :question_id }

  scope :with_content, -> { excluding(without_content) }
  scope :without_content, -> do
    where(description: "")
      .where.missing(:images)
      .where.missing(:documents)
      .where.missing(:videos)
  end

  sig { params(ordered_array: T::Array[T.any(Integer, String)]).void }
  def self.order_options(ordered_array)
    ordered_array.each_with_index do |option_id, order|
      find(option_id).update_column(:given_order, order + 1)
    end
  end

  sig { params(question_id: T.nilable(Integer)).returns(Integer) }
  def self.last_position(question_id)
    where(question_id: question_id).maximum("given_order") || 0
  end

  sig { returns(Integer) }
  def total_votes
    answers.count + T.cast(partial_results.sum(:amount), Integer)
  end

  sig { returns(T.any(Integer, Float)) }
  def total_votes_percentage
    question = T.must(self.question)
    question.options_total_votes.zero? ? 0 : (total_votes * 100.0) / question.options_total_votes
  end

  sig { returns(T::Boolean) }
  def with_read_more?
    description.present? || images.any? || documents.any? || videos.any?
  end
end
