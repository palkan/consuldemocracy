# typed: true
class Admin::Legislation::DraftVersionsController < Admin::Legislation::BaseController
  include Translatable

  load_and_authorize_resource :process, class: "Legislation::Process"
  load_and_authorize_resource :draft_version, class: "Legislation::DraftVersion", through: :process

  sig { void }
  def index
  end

  sig { void }
  def create
    if @draft_version.save
      link = legislation_process_draft_version_path(@process, @draft_version)
      notice = t("admin.legislation.draft_versions.create.notice", link: link)
      redirect_to admin_legislation_process_draft_versions_path, notice: notice
    else
      flash.now[:error] = t("admin.legislation.draft_versions.create.error")
      render :new
    end
  end

  sig { void }
  def update
    if @draft_version.update(draft_version_params)
      link = legislation_process_draft_version_path(@process, @draft_version)
      notice = t("admin.legislation.draft_versions.update.notice", link: link)
      edit_path = edit_admin_legislation_process_draft_version_path(@process, @draft_version)
      redirect_to edit_path, notice: notice
    else
      flash.now[:error] = t("admin.legislation.draft_versions.update.error")
      render :edit
    end
  end

  sig { void }
  def destroy
    @draft_version.destroy!
    notice = t("admin.legislation.draft_versions.destroy.notice")
    redirect_to admin_legislation_process_draft_versions_path, notice: notice
  end

  private

    sig { returns(ActionController::Parameters) }
    def draft_version_params
      params.require(:legislation_draft_version).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      [:status, :final_version, translation_params(Legislation::DraftVersion)]
    end
end
