# typed: strict
class Admin::BudgetsWizard::CreationTimelineComponent < ApplicationComponent
  sig { returns(String) }
  attr_reader :current_step

  sig { params(current_step: String).void }
  def initialize(current_step)
    @current_step = current_step
  end

  private

    sig { returns(T::Array[String]) }
    def steps
      %w[budget groups headings phases]
    end
end
