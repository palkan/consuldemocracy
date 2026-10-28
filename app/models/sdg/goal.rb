# typed: strict
class SDG::Goal < ApplicationRecord
  include SDG::Related

  validates :code, presence: true, uniqueness: true, inclusion: { in: 1..17 }

  has_many :targets, dependent: :destroy
  has_many :local_targets, dependent: :destroy

  sig { returns(String) }
  def title
    I18n.t("sdg.goals.goal_#{code}.title")
  end
  alias_method :long_title, :title

  sig { returns(String) }
  def title_in_two_lines
    I18n.t("sdg.goals.goal_#{code}.title_in_two_lines")
  end

  sig { returns(String) }
  def description
    I18n.t("sdg.goals.goal_#{code}.description")
  end

  sig { params(code: T.any(Integer, String)).returns(SDG::Goal) }
  def self.[](code)
    find_by!(code: code)
  end
end
