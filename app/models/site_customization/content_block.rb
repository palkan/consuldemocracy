# typed: strict
class SiteCustomization::ContentBlock < ApplicationRecord
  VALID_BLOCKS = %w[top_links footer footer_legal subnavigation_left subnavigation_right].freeze

  validates :locale, presence: true, inclusion: { in: ->(*) { Setting.enabled_locales.map(&:to_s) }}
  validates :name, presence: true, uniqueness: { scope: :locale }, inclusion: { in: ->(*) { VALID_BLOCKS }}

  sig { params(name: String, locale: T.any(String, Symbol)).returns(T.nilable(String)) }
  def self.block_for(name, locale = T.cast(I18n.locale, Symbol))
    find_by(name: name, locale: locale)&.body
  end
end
