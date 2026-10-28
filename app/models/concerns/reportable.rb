# typed: strict
module Reportable
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ApplicationRecord }

  included do
    has_one :report, as: :process, inverse_of: :process, dependent: :destroy
    accepts_nested_attributes_for :report

    Report::KINDS.each do |kind|
      scope "#{kind}_enabled", -> { joins(:report).where("reports.#{kind}": true) }
    end
  end

  sig { returns(Report) }
  def report
    super || build_report
  end

  Report::KINDS.each do |kind|
    define_method "#{kind}_enabled?" do
      T.bind(self, Reportable).report.send(kind)
    end
    alias_method :"#{kind}_enabled", :"#{kind}_enabled?"

    define_method "#{kind}_enabled=" do |enabled|
      T.bind(self, Reportable).report.send("#{kind}=", enabled)
    end
  end
end
