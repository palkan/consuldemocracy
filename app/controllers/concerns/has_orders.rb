# typed: true
module HasOrders
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ActionController::Base }

  sig { returns(T.nilable(T::Array[String])) }
  attr_reader :valid_orders

  sig { returns(T.nilable(String)) }
  attr_reader :current_order

  included do
    helper_method :valid_orders, :current_order
  end

  module ClassMethods
    extend T::Sig

    sig do
      params(
        valid_orders: T.any(T::Array[String],
                            T.proc.params(controller: T.untyped).returns(T::Array[String])),
        "**": T.untyped
      ).void
    end
    def has_orders(valid_orders, **)
      T.bind(self, T.class_of(ActionController::Base))
      before_action(**) do |c|
        T.bind(self, ActionController::Base)
        @valid_orders = valid_orders.is_a?(Proc) ? valid_orders.call(c) : valid_orders.dup
        @valid_orders.delete("relevance") if params[:search].blank?
        @current_order = @valid_orders.include?(params[:order]) ? params[:order] : @valid_orders.first
      end
    end
  end
end
