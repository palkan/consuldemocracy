# typed: strict
module ReportAttributes
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ActionController::Base }

  private

    sig { returns(T::Array[Symbol]) }
    def report_attributes
      Report::KINDS.map { |kind| :"#{kind}_enabled" }
    end
end
