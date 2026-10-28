# typed: strict
class Admin::Settings::SDGConfigurationTabComponent < ApplicationComponent
  sig { returns(T::Array[String]) }
  def settings
    %w[
      sdg.process.debates
      sdg.process.proposals
      sdg.process.polls
      sdg.process.budgets
      sdg.process.legislation
    ]
  end
end
