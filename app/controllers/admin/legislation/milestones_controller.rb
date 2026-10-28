# typed: true
class Admin::Legislation::MilestonesController < Admin::MilestonesController
  include FeatureFlags

  feature_flag :legislation

  sig { void }
  def index
    @process = milestoneable
  end

  private

    sig { returns(::Legislation::Process) }

    def milestoneable
      ::Legislation::Process.find(params[:process_id])
    end

    sig { returns(String) }

    def milestoneable_path
      admin_legislation_process_milestones_path(milestoneable)
    end
end
