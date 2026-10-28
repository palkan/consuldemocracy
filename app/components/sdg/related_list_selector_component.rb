# typed: strict
class SDG::RelatedListSelectorComponent < ApplicationComponent
  GoalOrTarget = T.type_alias { T.any(SDG::Goal, SDG::Target, SDG::LocalTarget) }

  sig { returns(ActionView::Helpers::FormBuilder) }
  attr_reader :f

  delegate :new_window_link_to, to: :helpers

  sig { params(form: ActionView::Helpers::FormBuilder).void }
  def initialize(form)
    @f = form
  end

  sig { returns(T::Array[T::Hash[Symbol, T.untyped]]) }
  def sdg_related_suggestions
    goals_and_targets.map { |goal_or_target| suggestion_tag_for(goal_or_target) }
  end

  sig { returns(T::Array[GoalOrTarget]) }
  def goals_and_targets
    goals.map do |goal|
      global_and_local_targets = goal.targets + goal.local_targets
      [goal, global_and_local_targets.sort]
    end.flatten
  end

  sig { params(goal_or_target: GoalOrTarget).returns(T::Hash[Symbol, T.untyped]) }
  def suggestion_tag_for(goal_or_target)
    {
      tag: goal_or_target.code_and_title.gsub(",", ""),
      display_text: text_for(goal_or_target),
      title: goal_or_target.long_title,
      value: goal_or_target.code
    }
  end

  sig { returns(T.nilable(T::Boolean)) }
  def render?
    SDG::ProcessEnabled.new(f.object).enabled?
  end

  private

    sig { returns(SDG::Goal::PrivateRelation) }
    def goals
      SDG::Goal.order(:code)
    end

    sig { params(checkbox_form: T.untyped).returns(ActiveSupport::SafeBuffer) }
    def goal_field(checkbox_form)
      goal = checkbox_form.object

      checkbox_form.check_box(data: { code: goal.code }) +
        checkbox_form.label { render(SDG::Goals::IconComponent.new(goal)) }
    end

    sig { params(goal_or_target: GoalOrTarget).returns(T.nilable(String)) }
    def text_for(goal_or_target)
      if goal_or_target.class.name == "SDG::Goal"
        t("sdg.related_list_selector.goal_identifier", code: goal_or_target.code)
      else
        goal_or_target.code
      end
    end

    sig { returns(String) }
    def relatable_name
      f.object.model_name.human.downcase
    end
end
