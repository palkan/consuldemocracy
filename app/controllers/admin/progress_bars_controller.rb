# typed: true
class Admin::ProgressBarsController < Admin::BaseController
  include Translatable

  before_action :load_progressable
  before_action :load_progress_bar, only: [:edit, :update, :destroy]
  helper_method :progress_bars_index

  sig { void }
  def index
  end

  sig { void }
  def new
    @progress_bar = @progressable.progress_bars.new
  end

  sig { void }
  def create
    @progress_bar = @progressable.progress_bars.new(progress_bar_params)
    if @progress_bar.save
      redirect_to progress_bars_index, notice: t("admin.progress_bars.create.notice")
    else
      render :new
    end
  end

  sig { void }
  def edit
  end

  sig { void }
  def update
    if @progress_bar.update(progress_bar_params)
      redirect_to progress_bars_index, notice: t("admin.progress_bars.update.notice")
    else
      render :edit
    end
  end

  sig { void }
  def destroy
    @progress_bar.destroy!
    redirect_to progress_bars_index, notice: t("admin.progress_bars.delete.notice")
  end

  private

    sig { returns(ActionController::Parameters) }
    def progress_bar_params
      params.require(:progress_bar).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      [
        :kind,
        :percentage,
        translation_params(ProgressBar)
      ]
    end

    sig { void }
    def load_progressable
      @progressable = progressable
    end

    sig { returns(T.any(Budget::Investment, Proposal, ::Legislation::Process)) }

    def progressable
      raise "This method must be implemented in subclass #{self.class.name}"
    end

    sig { void }
    def load_progress_bar
      @progress_bar = progressable.progress_bars.find(params[:id])
    end

    sig { returns(String) }

    def progress_bars_index
      admin_polymorphic_path(@progressable.progress_bars.new)
    end
end
