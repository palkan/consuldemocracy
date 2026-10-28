# typed: strict
class SDG::Phase < ApplicationRecord
  include Cardable

  enum :kind, { sensitization: 0, planning: 1, monitoring: 2 }
  validates :kind, presence: true, uniqueness: true

  sig { params(kind: T.any(String, Symbol)).returns(SDG::Phase) }
  def self.[](kind)
    find_by!(kind: kind)
  end

  sig { returns(String) }
  def title
    self.class.human_attribute_name("kind.#{kind}")
  end
end
