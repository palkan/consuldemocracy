# typed: strict
class SDG::Goals::PlainTagListComponent < ApplicationComponent
  include SDG::TagList

  private

    sig { returns(T::Array[String]) }
    def tags
      [*goal_tags, see_more_link].compact_blank
    end

    sig { returns(T::Array[String]) }
    def goal_tags
      tag_records.map do |goal|
        render SDG::TagComponent.new(goal)
      end
    end

    sig { returns(Symbol) }
    def association_name
      :sdg_goals
    end
end
