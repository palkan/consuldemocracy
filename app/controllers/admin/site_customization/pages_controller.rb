# typed: true
class Admin::SiteCustomization::PagesController < Admin::SiteCustomization::BaseController
  include Translatable

  load_and_authorize_resource :page, class: "SiteCustomization::Page"

  sig { void }
  def index
    @pages = SiteCustomization::Page.order(:slug).page(params[:page])
  end

  sig { void }
  def create
    if @page.save
      notice = t("admin.site_customization.pages.create.notice")
      redirect_to admin_site_customization_pages_path, notice: notice
    else
      flash.now[:error] = t("admin.site_customization.pages.create.error")
      render :new
    end
  end

  sig { void }
  def update
    if @page.update(page_params)
      notice = t("admin.site_customization.pages.update.notice")
      redirect_to admin_site_customization_pages_path, notice: notice
    else
      flash.now[:error] = t("admin.site_customization.pages.update.error")
      render :edit
    end
  end

  sig { void }
  def destroy
    @page.destroy!
    notice = t("admin.site_customization.pages.destroy.notice")
    redirect_to admin_site_customization_pages_path, notice: notice
  end

  private

    sig { returns(ActionController::Parameters) }
    def page_params
      params.require(:site_customization_page).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      attributes = [:slug, :more_info_flag, :print_content_flag, :status]

      [*attributes, translation_params(SiteCustomization::Page)]
    end
end
