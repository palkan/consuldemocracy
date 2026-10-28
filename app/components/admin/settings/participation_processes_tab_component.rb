# typed: strict
class Admin::Settings::ParticipationProcessesTabComponent < ApplicationComponent
  sig { returns(T::Array[String]) }
  def settings
    %w[
      process.debates
      process.proposals
      process.polls
      process.budgets
      process.legislation
    ]
  end
end
