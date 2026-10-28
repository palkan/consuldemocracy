# typed: true
class Admin::Legislation::ProgressBarsController < Admin::ProgressBarsController
  include FeatureFlags

  feature_flag :legislation

  sig { void }
  def index
    @process = progressable
  end

  private

    sig { returns(::Legislation::Process) }

    def progressable
      ::Legislation::Process.find(params[:process_id])
    end
end
