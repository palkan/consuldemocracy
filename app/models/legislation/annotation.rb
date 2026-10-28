# typed: strict
class Legislation::Annotation < ApplicationRecord
  COMMENTS_PAGE_SIZE = 5
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  serialize :ranges, type: Array

  belongs_to :draft_version, foreign_key: "legislation_draft_version_id", inverse_of: :annotations
  belongs_to :author, -> { with_hidden }, class_name: "User", inverse_of: :legislation_annotations
  has_many :comments, as: :commentable, inverse_of: :commentable, dependent: :destroy

  validates :text, presence: true
  validates :quote, presence: true
  validates :draft_version, presence: true
  validates :author, presence: true

  before_save :store_range, :store_context
  after_create :create_first_comment

  sig { void }
  def store_range
    self.range_start = ranges.first["start"]
    self.range_start_offset = ranges.first["startOffset"]
    self.range_end = ranges.first["end"]
    self.range_end_offset = ranges.first["endOffset"]
  end

  sig { returns(String) }
  def store_context
    html = T.must(draft_version).body_html
    doc = Nokogiri::HTML(html)

    selector_start = "/html/body/#{range_start}"
    el_start = doc.at_xpath(selector_start)

    selector_end = "/html/body/#{range_end}"
    el_end = doc.at_xpath(selector_end)

    range_start_offset = T.must(self.range_start_offset)
    remainder_el_start = el_start.text[0..range_start_offset - 1] unless range_start_offset.zero?
    remainder_el_end = el_end.text[range_end_offset..-1]

    self.context = "#{remainder_el_start}<span class=annotator-hl>#{quote}</span>#{remainder_el_end}"
  rescue
    "<span class=annotator-hl>#{quote}</span>"
  end

  sig { void }
  def create_first_comment
    comments.create(body: text, user: author)
  end

  sig { returns(T.nilable(String)) }
  def title
    T.must(text)[0..50]
  end

  sig { returns(Integer) }
  def weight
    T.must(comments_count) + T.cast(comments.sum(:cached_votes_total), Integer)
  end

  sig { returns(T::Boolean) }
  def comments_closed?
    !T.must(T.must(draft_version).process).allegations_phase.open?
  end
end
