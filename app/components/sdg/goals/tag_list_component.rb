# typed: strict
class SDG::Goals::TagListComponent < ApplicationComponent
  include SDG::TagList

  private

    sig { returns(Symbol) }
    def association_name
      :sdg_goals
    end

    sig { returns(T.class_of(ApplicationRecord)) }
    def related_model
      record.class
    end
end
