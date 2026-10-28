# typed: strict
class Admin::Widget::Cards::NewComponent < ApplicationComponent
  include Header

  sig { returns(::Widget::Card) }
  attr_reader :card

  sig { returns(String) }
  attr_reader :index_path

  sig { returns(T.nilable(String)) }
  attr_reader :form_path

  sig { params(card: ::Widget::Card, index_path: String, form_path: T.nilable(String)).void }
  def initialize(card, index_path:, form_path: nil)
    @card = card
    @index_path = index_path
    @form_path = form_path
  end

  private

    sig { override.returns(String) }
    def title
      if card.header_or_sdg_header?
        t("admin.homepage.new.header_title")
      else
        t("admin.homepage.new.card_title")
      end
    end
end
