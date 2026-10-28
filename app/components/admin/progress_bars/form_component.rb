# typed: strict
class Admin::ProgressBars::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  sig { returns(ProgressBar) }
  attr_reader :progress_bar

  sig { params(progress_bar: ProgressBar).void }
  def initialize(progress_bar)
    @progress_bar = progress_bar
  end

  private

    sig { returns(T::Hash[Symbol, T.nilable(Integer)]) }
    def progress_options
      { min: ProgressBar::RANGE.min, max: ProgressBar::RANGE.max, step: 1 }
    end
end
