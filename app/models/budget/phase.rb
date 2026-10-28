# typed: strict
class Budget
  class Phase < ApplicationRecord
    PHASE_KINDS = %w[informing accepting reviewing selecting valuating publishing_prices balloting
                     reviewing_ballots finished].freeze
    PUBLISHED_PRICES_PHASES = %w[publishing_prices balloting reviewing_ballots finished].freeze
    DESCRIPTION_MAX_LENGTH = 2000

    translates :name, touch: true
    translates :summary, touch: true
    translates :description, touch: true
    translates :main_link_text, touch: true
    translates :main_link_url, touch: true
    include Globalizable
    include Imageable

    belongs_to :budget, touch: true
    belongs_to :next_phase, class_name: name, inverse_of: :prev_phase
    has_one :prev_phase, class_name: name, foreign_key: :next_phase_id, inverse_of: :next_phase

    validates_translation :name, presence: true
    validates_translation :description, length: { maximum: ->(*) { DESCRIPTION_MAX_LENGTH }}
    validates_translation :main_link_url, presence: true, unless: ->(record) { record.main_link_text.blank? }
    validates :budget, presence: true
    validates :kind, presence: true, uniqueness: { scope: :budget }, inclusion: { in: ->(*) { PHASE_KINDS }}
    validate :invalid_dates_range?
    validate :prev_phase_dates_valid?
    validate :next_phase_dates_valid?

    after_save :adjust_date_ranges

    scope :enabled,           -> { where(enabled: true) }
    scope :published,         -> { enabled.where.not(kind: "drafting") }

    PHASE_KINDS.each do |phase|
      define_singleton_method(phase) { find_by(kind: phase) }
    end

    sig { params(phase: String).returns(T::Array[String]) }
    def self.kind_or_later(phase)
      T.must(PHASE_KINDS[T.must(PHASE_KINDS.index(phase))..-1])
    end

    sig { returns(T.nilable(Budget::Phase)) }
    def next_enabled_phase
      next_phase&.enabled? ? next_phase : next_phase&.next_enabled_phase
    end

    sig { returns(T.nilable(Budget::Phase)) }
    def prev_enabled_phase
      prev_phase&.enabled? ? prev_phase : prev_phase&.prev_enabled_phase
    end

    sig { returns(T.nilable(ActiveModel::Error)) }
    def invalid_dates_range?
      starts_at = self.starts_at
      ends_at = self.ends_at

      if starts_at.present? && ends_at.present? && starts_at >= ends_at
        errors.add(:starts_at, I18n.t("budgets.phases.errors.dates_range_invalid"))
      end
    end

    sig { returns(T::Boolean) }
    def valuating_or_later?
      in_phase_or_later?("valuating")
    end

    sig { returns(T::Boolean) }
    def publishing_prices_or_later?
      in_phase_or_later?("publishing_prices")
    end

    sig { returns(T::Boolean) }
    def balloting_or_later?
      in_phase_or_later?("balloting")
    end

    sig { returns(T::Boolean) }
    def current?
      T.must(budget).current_phase == self
    end

    private

      sig { void }
      def adjust_date_ranges
        if enabled?
          next_enabled_phase&.update_column(:starts_at, ends_at)
          prev_enabled_phase&.update_column(:ends_at, starts_at)
        elsif saved_change_to_enabled?
          next_enabled_phase&.update_column(:starts_at, starts_at)
        end
      end

      sig { void }
      def prev_phase_dates_valid?
        if enabled? && starts_at.present? && (phase = prev_enabled_phase).present?
          phase.assign_attributes(ends_at: starts_at)
          if phase.invalid_dates_range?
            phase_name = phase.name
            error = I18n.t("budgets.phases.errors.prev_phase_dates_invalid", phase_name: phase_name)
            errors.add(:starts_at, error)
          end
        end
      end

      sig { void }
      def next_phase_dates_valid?
        if enabled? && ends_at.present? && (phase = next_enabled_phase).present?
          phase.assign_attributes(starts_at: ends_at)
          if phase.invalid_dates_range?
            phase_name = phase.name
            error = I18n.t("budgets.phases.errors.next_phase_dates_invalid", phase_name: phase_name)
            errors.add(:ends_at, error)
          end
        end
      end

      sig { params(phase: String).returns(T::Boolean) }
      def in_phase_or_later?(phase)
        self.class.kind_or_later(phase).include?(kind)
      end
  end
end
