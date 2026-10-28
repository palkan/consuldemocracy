# typed: strict
class SDG::Target < ApplicationRecord
  include SDG::Related

  validates :code, presence: true, uniqueness: true
  validates :goal, presence: true

  belongs_to :goal
  has_many :local_targets, dependent: :destroy

  sig { returns(String) }
  def title
    I18n.t("#{i18n_key}.short_title", default: long_title, fallback: nil)
  end

  sig { returns(String) }
  def long_title
    I18n.t("#{i18n_key}.long_title")
  end

  sig { params(code: T.any(String, Numeric)).returns(SDG::Target) }
  def self.[](code)
    find_by!(code: code)
  end

  private

    sig { returns(String) }
    def i18n_key
      "sdg.goals.goal_#{T.must(goal).code}.targets.target_#{code_key}"
    end

    sig { returns(String) }
    def code_key
      code.gsub(".", "_").upcase
    end
end
