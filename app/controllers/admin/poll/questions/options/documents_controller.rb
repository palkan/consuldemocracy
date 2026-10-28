# typed: true
class Admin::Poll::Questions::Options::DocumentsController < Admin::Poll::BaseController
  include DocumentAttributes

  load_and_authorize_resource :option, class: "::Poll::Question::Option"

  sig { void }
  def index
  end

  sig { void }
  def create
    @option.attributes = documents_params
    authorize! :update, @option

    if @option.save
      redirect_to admin_option_documents_path(@option),
                  notice: t("admin.documents.create.success_notice")
    else
      render :index
    end
  end

  private

    sig { returns(ActionController::Parameters) }
    def documents_params
      params.require(:poll_question_option).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      [documents_attributes: document_attributes]
    end
end
