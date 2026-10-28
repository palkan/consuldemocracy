# typed: true
class Admin::Poll::Questions::Options::ImagesController < Admin::Poll::BaseController
  include ImageAttributes

  load_and_authorize_resource :option, class: "::Poll::Question::Option"
  load_and_authorize_resource only: [:destroy]

  sig { void }
  def index
  end

  sig { void }
  def new
  end

  sig { void }
  def create
    @option.attributes = images_params
    authorize! :update, @option

    if @option.save
      redirect_to admin_option_images_path(@option),
                  notice: t("flash.actions.create.poll_question_option_image")
    else
      render :new
    end
  end

  sig { void }
  def destroy
    @image.destroy!

    redirect_to admin_option_images_path(@image.imageable),
                notice: t("flash.actions.destroy.poll_question_option_image")
  end

  private

    sig { returns(ActionController::Parameters) }
    def images_params
      params.require(:poll_question_option).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      [:option_id, images_attributes: image_attributes]
    end
end
