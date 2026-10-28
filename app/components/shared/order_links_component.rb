# typed: strict
class Shared::OrderLinksComponent < ApplicationComponent
  sig { returns(String) }
  attr_reader :i18n_namespace

  sig { returns(T.nilable(String)) }
  attr_reader :anchor

  delegate :current_path_with_query_params, :current_order, :valid_orders, to: :helpers

  sig { params(i18n_namespace: String, anchor: T.nilable(String)).void }
  def initialize(i18n_namespace, anchor: nil)
    @i18n_namespace = i18n_namespace
    @anchor = anchor
  end

  private

    sig { params(order: String).returns(T.nilable(String)) }
    def html_class(order)
      "is-active" if order == current_order
    end

    sig { params(order: String).returns(Symbol) }
    def tag_name(order)
      if order == current_order
        :h2
      else
        :span
      end
    end

    sig { params(order: String).returns(String) }
    def link_path(order)
      current_path_with_query_params(order: order, page: 1, anchor: anchor)
    end

    sig { params(order: String).returns(String) }
    def link_text(order)
      t("#{i18n_namespace}.orders.#{order}")
    end
end
