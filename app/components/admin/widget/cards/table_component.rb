# typed: strict
class Admin::Widget::Cards::TableComponent < ApplicationComponent
  sig { returns(T::Enumerable[::Widget::Card]) }
  attr_reader :cards

  sig { returns(String) }
  attr_reader :no_cards_message

  sig { returns(T::Hash[Symbol, T.untyped]) }
  attr_reader :options

  sig { params(cards: T::Enumerable[::Widget::Card], no_cards_message: String, options: T.untyped).void }
  def initialize(cards, no_cards_message:, **options)
    @cards = cards
    @no_cards_message = no_cards_message
    @options = options
  end

  private

    sig { params(attribute: Symbol).returns(String) }
    def attribute_name(attribute)
      ::Widget::Card.human_attribute_name(attribute)
    end

    sig { returns(T::Boolean) }
    def header_section?
      T.must(cards.first).header_or_sdg_header?
    end
end
