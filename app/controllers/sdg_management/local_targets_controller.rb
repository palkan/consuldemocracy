# typed: true
class SDGManagement::LocalTargetsController < SDGManagement::BaseController
  include Translatable

  load_and_authorize_resource class: "SDG::LocalTarget"

  sig { void }
  def index
    @local_targets = @local_targets.sort
  end

  sig { void }
  def new
  end

  sig { void }
  def create
    if @local_target.save
      redirect_to sdg_management_local_targets_path, notice: t("sdg_management.local_targets.create.notice")
    else
      render :new
    end
  end

  sig { void }
  def edit
  end

  sig { void }
  def update
    if @local_target.update(local_target_params)
      redirect_to sdg_management_local_targets_path, notice: t("sdg_management.local_targets.update.notice")
    else
      render :edit
    end
  end

  sig { void }
  def destroy
    @local_target.destroy!
    redirect_to sdg_management_local_targets_path, notice: t("sdg_management.local_targets.destroy.notice")
  end

  private

    sig { returns(ActionController::Parameters) }
    def local_target_params
      params.require(:sdg_local_target).permit(allowed_params)
    end

    sig { returns(T::Array[T.untyped]) }
    def allowed_params
      translations_attributes = translation_params(::SDG::LocalTarget)

      [:code, :target_id, translations_attributes]
    end
end
