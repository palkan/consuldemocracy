# typed: strict
class Budget
  class Group < ApplicationRecord
    include Sluggable

    translates :name, touch: true
    include Globalizable

    translation_class_delegate :budget

    class Translation < Globalize::ActiveRecord::Translation
      extend T::Sig

      validate :name_uniqueness_by_budget

      sig { void }
      def name_uniqueness_by_budget
        if T.must(budget).groups.joins(:translations)
                 .where(name: name)
                 .where.not("budget_group_translations.budget_group_id": budget_group_id).any?
          errors.add(:name, I18n.t("errors.messages.taken"))
        end
      end
    end

    belongs_to :budget

    has_many :headings, dependent: :destroy

    validates_translation :name, presence: true
    validates :budget_id, presence: true
    validates :slug, presence: true, format: /\A[a-z0-9\-_]+\z/

    sig { returns(T::Array[Budget::Group]) }
    def self.sort_by_name
      all.sort_by(&:name)
    end

    sig { returns(T::Boolean) }
    def multiple_headings?
      headings.size > 1
    end

    private

      sig { returns(T::Boolean) }
      def generate_slug?
        slug.nil? || T.must(budget).drafting?
      end
  end
end
