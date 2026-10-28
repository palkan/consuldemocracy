# typed: strict
module Filterable
  extend ActiveSupport::Concern

  included do
    scope :by_date_range, ->(date_range) { where(created_at: date_range) }
  end

  module ClassMethods
    extend T::Helpers
    extend T::Sig

    requires_ancestor { T.class_of(ApplicationRecord) }

    sig { params(params: T.untyped).returns(ActiveRecord::Relation) }
    def filter_by(params)
      resources = all
      (params.presence || {}).each do |filter, value|
        if allowed_filter?(filter, value)
          resources = resources.send("by_#{filter}", value)
        end
      end
      resources
    end

    sig { params(filter: T.any(String, Symbol), value: T.untyped).returns(T.nilable(T::Boolean)) }
    def allowed_filter?(filter, value)
      return if value.blank?

      ["date_range", "goal", "target"].include?(filter)
    end
  end
end
