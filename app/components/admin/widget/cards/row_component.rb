# typed: strict
class Admin::Widget::Cards::RowComponent < ApplicationComponent
  sig { returns(::Widget::Card) }
  attr_reader :card

  sig { returns(T::Hash[Symbol, T.untyped]) }
  attr_reader :options

  sig { params(card: ::Widget::Card, options: T.untyped).void }
  def initialize(card, **options)
    @card = card
    @options = options
  end

  private

    sig { returns(T::Boolean) }
    def header_section?
      card.header_or_sdg_header?
    end
end
