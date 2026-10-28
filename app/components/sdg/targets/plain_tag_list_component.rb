# typed: strict
class SDG::Targets::PlainTagListComponent < ApplicationComponent
  include SDG::TagList

  private

    sig { returns(T::Array[String]) }
    def tags
      [*target_tags, see_more_link].compact_blank
    end

    sig { returns(T::Array[ActiveSupport::SafeBuffer]) }
    def target_tags
      tag_records.map do |target|
        tag.span(render(SDG::TagComponent.new(target)), data: { code: target.code })
      end
    end

    sig { returns(Symbol) }
    def association_name
      :sdg_targets
    end
end
