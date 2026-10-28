# typed: strict
class Poll
  class Voter < ApplicationRecord
    VALID_ORIGINS = %w[web booth letter].freeze

    belongs_to :poll
    belongs_to :user
    belongs_to :geozone
    belongs_to :booth_assignment
    belongs_to :officer_assignment
    belongs_to :officer

    validates :poll_id, presence: true
    validates :user_id, presence: true
    validates :booth_assignment_id, presence: true, if: ->(voter) { voter.origin == "booth" }
    validates :officer_assignment_id, presence: true, if: ->(voter) { voter.origin == "booth" }

    validates :document_number, presence: true, unless: :skip_user_verification?
    validates :origin, inclusion: { in: ->(*) { VALID_ORIGINS }}

    before_validation :set_demographic_info, :set_document_info, :set_denormalized_booth_assignment_id

    scope :web,    -> { where(origin: "web") }
    scope :booth,  -> { where(origin: "booth") }
    scope :letter, -> { where(origin: "letter") }

    sig { void }
    def set_demographic_info
      user = self.user
      return if user.blank?

      self.gender  = user.gender
      self.age     = user.age
      self.geozone = user.geozone
    end

    sig { void }
    def set_document_info
      user = self.user
      return if user.blank?

      self.document_type   = user.document_type
      self.document_number = user.document_number
    end

    sig { returns(T::Boolean) }
    def skip_user_verification?
      Setting["feature.user.skip_verification"].present?
    end

    private

      sig { void }
      def set_denormalized_booth_assignment_id
        self.booth_assignment_id ||= officer_assignment&.booth_assignment_id
      end
  end
end
