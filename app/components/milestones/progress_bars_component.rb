# typed: strict
class Milestones::ProgressBarsComponent < ApplicationComponent
  sig { returns(Milestoneable) }
  attr_reader :milestoneable

  sig { params(milestoneable: Milestoneable).void }
  def initialize(milestoneable)
    @milestoneable = milestoneable
  end

  sig { returns(T.nilable(ProgressBar)) }
  def render?
    primary_progress_bar
  end

  private

    sig { returns(T.nilable(ProgressBar)) }
    def primary_progress_bar
      milestoneable.primary_progress_bar
    end

    sig { returns(ProgressBar::PrivateAssociationRelation) }
    def secondary_progress_bars
      milestoneable.secondary_progress_bars
    end

    sig { params(progress_bar: ProgressBar, label: T.nilable(String)).returns(ActiveSupport::SafeBuffer) }
    def progress_tag_for(progress_bar, label:)
      text = number_to_percentage(progress_bar.percentage, precision: 0)

      tag.div class: "progress",
              role: "progressbar",
              "aria-label": label,
              "aria-valuenow": progress_bar.percentage,
              "aria-valuetext": "#{progress_bar.percentage}%",
              "aria-valuemax": ProgressBar::RANGE.max,
              "aria-valuemin": "0",
              tabindex: "0" do
        tag.span(class: "progress-meter", style: "width: #{progress_bar.percentage}%;") +
          tag.p(text, class: "progress-meter-text")
      end
    end
end
