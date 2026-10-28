# typed: true
class Admin::Legislation::QuestionsController < Admin::Legislation::BaseController
  include Translatable

  load_and_authorize_resource :process, class: "Legislation::Process"
  load_and_authorize_resource :question, class: "Legislation::Question", through: :process

  sig { void }
  def index
    @questions = @process.questions
  end

  sig { void }
  def new
  end

  sig { void }
  def create
    @question.author = current_user
    if @question.save
      notice = t("admin.legislation.questions.create.notice", link: question_path)
      redirect_to admin_legislation_process_questions_path, notice: notice
    else
      flash.now[:error] = t("admin.legislation.questions.create.error")
      render :new
    end
  end

  sig { void }
  def update
    if @question.update(question_params)
      notice = t("admin.legislation.questions.update.notice", link: question_path)
      redirect_to edit_admin_legislation_process_question_path(@process, @question), notice: notice
    else
      flash.now[:error] = t("admin.legislation.questions.update.error")
      render :edit
    end
  end

  sig { void }
  def destroy
    @question.destroy!
    notice = t("admin.legislation.questions.destroy.notice")
    redirect_to admin_legislation_process_questions_path, notice: notice
  end

  private

    sig { returns(String) }

    def question_path
      legislation_process_question_path(@process, @question)
    end

    sig { returns(ActionController::Parameters) }
    def question_params
      params.require(:legislation_question).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      [
        translation_params(::Legislation::Question),
        question_options_attributes: [:id, :_destroy,
                                      translation_params(::Legislation::QuestionOption)]
      ]
    end
end
