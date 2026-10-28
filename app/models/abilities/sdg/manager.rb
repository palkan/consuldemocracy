# typed: strict
class Abilities::SDG::Manager
  extend T::Sig
  include CanCan::Ability

  sig { params(user: User).void }
  def initialize(user)
    merge Abilities::Common.new(user)

    can :read, ::SDG::Target
    can :manage, ::SDG::LocalTarget
    can :read, WebSection, name: "sdg"
    can [:create, :update, :destroy], Widget::Card do |card|
      card.cardable_type == "SDG::Phase" || card.cardable&.name == "sdg"
    end
  end
end
