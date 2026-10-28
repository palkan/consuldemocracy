# typed: true
class Admin::SiteCustomization::InformationTextsController < Admin::SiteCustomization::BaseController
  before_action :delete_translations, only: [:update]

  sig { void }
  def index
    @tab = params[:tab] || :basic
    @content = I18nContent.content_for(@tab)
  end

  sig { void }
  def update
    I18nContent.update(content_params, enabled_translations)

    redirect_to admin_site_customization_information_texts_path,
                notice: t("flash.actions.update.translation")
  end

  private

    sig { returns(T::Array[T.untyped]) }
    def content_params
      params.require(:contents).values
    end

    sig { void }

    def delete_translations
      languages_to_delete = params[:enabled_translations].select { |_, v| v == "0" }.keys

      languages_to_delete.each do |locale|
        I18nContentTranslation.where(locale: locale).destroy_all
      end
    end

    sig { returns(T::Array[String]) }

    def enabled_translations
      params.fetch(:enabled_translations, {}).select { |_, v| v == "1" }.keys
    end
end
