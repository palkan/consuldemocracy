# typed: strict
module SDG::Related
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig
  include Comparable

  requires_ancestor { ApplicationRecord }

  RELATABLE_TYPES = T.let(%w[
    Budget::Investment
    Debate
    Legislation::Process
    Legislation::Proposal
    Poll
    Proposal
  ].freeze, T::Array[String])

  included do
    has_many :relations, as: :related_sdg, dependent: :destroy

    RELATABLE_TYPES.each do |relatable_type|
      has_many relatable_type.constantize.table_name.to_sym,
               through: :relations,
               source: :relatable,
               source_type: relatable_type
    end
  end

  sig { returns(T::Array[T.untyped]) }
  def relatables
    relations.map(&:relatable)
  end

  sig { params(goal_or_target: Object).returns(T.nilable(Integer)) }
  def <=>(goal_or_target)
    if goal_or_target.class.ancestors.include?(SDG::Related)
      subcodes <=> T.cast(goal_or_target, SDG::Related).subcodes
    end
  end

  sig { returns(T::Array[Integer]) }
  def subcodes
    code.to_s.split(".").map do |subcode|
      if subcode.to_i.positive?
        subcode.to_i
      else
        subcode.to_i(36) * 1000
      end
    end
  end

  sig { returns(String) }
  def code_and_title
    "#{code}. #{title}"
  end
end
