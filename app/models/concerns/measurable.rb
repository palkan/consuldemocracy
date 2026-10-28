# typed: strict
module Measurable
  extend ActiveSupport::Concern

  module ClassMethods
    extend T::Helpers
    extend T::Sig

    requires_ancestor { T.class_of(ApplicationRecord) }

    sig { returns(Integer) }
    def title_max_length
      @title_max_length ||= T.let(columns.find { |c| c.name == "title" }&.limit || 80, T.nilable(Integer))
    end

    sig { returns(Integer) }
    def responsible_name_max_length
      @responsible_name_max_length ||= T.let(
        columns.find { |c| c.name == "responsible_name" }&.limit || 60,
        T.nilable(Integer)
      )
    end

    sig { returns(Integer) }
    def question_max_length
      140
    end

    sig { returns(Integer) }
    def description_max_length
      6000
    end

    sig { returns(Integer) }
    def description_min_length
      10
    end
  end
end
