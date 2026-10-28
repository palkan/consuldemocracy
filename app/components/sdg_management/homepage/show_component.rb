# typed: strict
class SDGManagement::Homepage::ShowComponent < ApplicationComponent
  include Header

  sig { returns(T.nilable(Widget::Card)) }
  attr_reader :header_card

  sig { returns(SDG::Phase::PrivateRelation) }
  attr_reader :phases

  sig { params(header_card: T.nilable(Widget::Card), phases: SDG::Phase::PrivateRelation).void }
  def initialize(header_card, phases)
    @header_card = header_card
    @phases = phases
  end

  private

    sig { override.returns(String) }
    def title
      t("sdg_management.homepage.title")
    end

    sig { params(phase: SDG::Phase).returns(String) }
    def create_card_text(phase)
      t("sdg_management.homepage.create_card", phase: phase.title.downcase)
    end

    sig { returns(String) }
    def no_cards_message
      t("sdg_management.homepage.no_cards")
    end
end
