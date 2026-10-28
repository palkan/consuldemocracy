# typed: true
class Admin::MachineLearningController < Admin::BaseController
  before_action :load_machine_learning_job, only: [:show, :execute]

  sig { void }
  def show
  end

  sig { void }
  def execute
    @machine_learning_job.update!(script: params[:script],
                                  user: current_user,
                                  started_at: Time.current,
                                  finished_at: nil,
                                  error: nil)

    ::MachineLearning.new(@machine_learning_job).run

    redirect_to admin_machine_learning_path,
                notice: t("admin.machine_learning.script_info", email: T.must(current_user).email)
  end

  sig { void }
  def cancel
    Delayed::Job.where(queue: "machine_learning").destroy_all
    MachineLearningJob.destroy_all

    redirect_to admin_machine_learning_path,
                notice: t("admin.machine_learning.notice.delete_generated_content")
  end

  private

    sig { void }
    def load_machine_learning_job
      @machine_learning_job = MachineLearningJob.first_or_initialize
    end
end
