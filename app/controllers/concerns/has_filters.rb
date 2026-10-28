# typed: true
module HasFilters
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ActionController::Base }

  sig { returns(T.nilable(T::Array[String])) }
  attr_reader :valid_filters

  sig { returns(T.nilable(String)) }
  attr_reader :current_filter

  included do
    helper_method :valid_filters, :current_filter
  end

  module ClassMethods
    extend T::Sig

    sig do
      params(
        valid_filters: T.any(T::Array[String],
                             T.proc.params(controller: T.untyped).returns(T::Array[String])),
        "**": T.untyped
      ).void
    end
    def has_filters(valid_filters, **)
      T.bind(self, T.class_of(ActionController::Base))
      before_action(**) do
        T.bind(self, ActionController::Base)
        @valid_filters = valid_filters.is_a?(Proc) ? valid_filters.call(self) : valid_filters
        @current_filter = @valid_filters.include?(params[:filter]) ? params[:filter] : @valid_filters.first
      end
    end
  end
end
