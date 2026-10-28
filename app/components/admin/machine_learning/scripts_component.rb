# typed: strict
class Admin::MachineLearning::ScriptsComponent < ApplicationComponent
  sig { returns(MachineLearningJob) }
  attr_reader :machine_learning_job

  sig { params(machine_learning_job: MachineLearningJob).void }
  def initialize(machine_learning_job)
    @machine_learning_job = machine_learning_job
    @scripts_info = T.let(nil, T.nilable(T::Array[T::Hash[Symbol, String]]))
  end

  private

    sig { returns(T::Array[[T.nilable(String), T::Hash[Symbol, T.nilable(String)]]]) }
    def script_select_options
      scripts_info.map { |info| [info[:name], { "aria-describedby": info[:name] }] }
    end

    sig { returns(T::Array[T::Hash[Symbol, String]]) }
    def scripts_info
      @scripts_info ||= ::MachineLearning.scripts_info
    end
end
