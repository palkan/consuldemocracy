# typed: strict
class SDG::FilterLinksComponent < ApplicationComponent
  sig { returns(T::Enumerable[T.any(SDG::Goal, SDG::Target, SDG::LocalTarget)]) }
  attr_reader :records

  sig { returns(T.class_of(ApplicationRecord)) }
  attr_reader :related_model

  sig { returns(T.nilable(ActiveSupport::SafeBuffer)) }
  attr_reader :see_more_link

  delegate :link_list, to: :helpers

  sig do
    params(
      records: T::Enumerable[T.any(SDG::Goal, SDG::Target, SDG::LocalTarget)],
      related_model: T.class_of(ApplicationRecord),
      see_more_link: T.nilable(ActiveSupport::SafeBuffer)
    ).void
  end
  def initialize(records, related_model, see_more_link: nil)
    @records = records
    @related_model = related_model
    @see_more_link = see_more_link
  end

  sig { returns(T::Array[T.untyped]) }
  def links
    [*sdg_links, see_more_link]
  end

  private

    sig { returns(T::Array[T::Array[T.untyped]]) }
    def sdg_links
      records.map do |goal_or_target|
        [
          render(SDG::TagComponent.new(goal_or_target)),
          index_by(parameter_name => goal_or_target.code),
          title: filter_text(goal_or_target),
          data: { code: goal_or_target.code }
        ]
      end
    end

    sig { params(goal_or_target: T.any(SDG::Goal, SDG::Target, SDG::LocalTarget)).returns(String) }
    def filter_text(goal_or_target)
      t("sdg.#{i18n_namespace}.filter.link",
        resources: related_model.model_name.human(count: :other),
        code: goal_or_target.code)
    end

    sig { params(advanced_search: T::Hash[String, T.untyped]).returns(String) }
    def index_by(advanced_search)
      if related_model.name == "Legislation::Proposal"
        legislation_process_proposals_path(params[:id], advanced_search: advanced_search,
                                                        filter: params[:filter])
      else
        polymorphic_path(related_model, advanced_search: advanced_search)
      end
    end

    sig { returns(String) }
    def i18n_namespace
      parameter_name.pluralize
    end

    sig { returns(String) }
    def parameter_name
      if records.first.is_a?(SDG::Goal)
        "goal"
      else
        "target"
      end
    end
end
