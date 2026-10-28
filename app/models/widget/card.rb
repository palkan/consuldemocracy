# typed: strict
class Widget::Card < ApplicationRecord
  include Imageable

  belongs_to :cardable, polymorphic: true

  translates :label,       touch: true
  translates :title,       touch: true
  translates :description, touch: true
  translates :link_text,   touch: true
  include Globalizable

  validates_translation :title, presence: true
  validates :link_url, presence: true, if: -> { T.bind(self, Widget::Card); !header? || link_text.present? }
  validates :order, numericality: { greater_than_or_equal_to: 1 }

  scope :sort_by_order, -> { order(:order, :created_at) }

  sig { returns(Widget::Card::PrivateRelation) }
  def self.header
    where(header: true)
  end

  sig { returns(Widget::Card::PrivateRelation) }
  def self.body
    where(header: false, cardable_id: nil).sort_by_order
  end

  sig { returns(T::Boolean) }
  def header_or_sdg_header?
    header? || sdg_header?
  end

  sig { returns(T::Boolean) }
  def sdg_header?
    cardable == WebSection.find_by!(name: "sdg")
  end
end
