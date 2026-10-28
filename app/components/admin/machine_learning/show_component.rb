# typed: strict
class Admin::MachineLearning::ShowComponent < ApplicationComponent
  include Header

  sig { returns(MachineLearningJob) }
  attr_reader :machine_learning_job

  sig { params(machine_learning_job: MachineLearningJob).void }
  def initialize(machine_learning_job)
    @machine_learning_job = machine_learning_job
  end

  sig { override.returns(String) }
  def title
    t("admin.machine_learning.title")
  end

  private

    sig { returns(T::Boolean) }
    def enabled?
      ::MachineLearning.enabled?
    end
end
