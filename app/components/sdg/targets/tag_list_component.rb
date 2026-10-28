# typed: strict
class SDG::Targets::TagListComponent < ApplicationComponent
  include SDG::TagList

  private

    sig { returns(Symbol) }
    def association_name
      :sdg_targets
    end

    sig { returns(T.class_of(ApplicationRecord)) }
    def related_model
      record.class
    end
end
