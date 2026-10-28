# typed: true
class Admin::Poll::BoothsController < Admin::Poll::BaseController
  load_and_authorize_resource class: "Poll::Booth"

  sig { void }
  def index
    @booths = @booths.search(params[:search])
    @booths = @booths.order(name: :asc).page(params[:page])
  end

  sig { void }
  def show
  end

  sig { void }
  def new
  end

  sig { void }
  def create
    if @booth.save
      redirect_to admin_booths_path, notice: t("flash.actions.create.poll_booth")
    else
      render :new
    end
  end

  sig { void }
  def edit
  end

  sig { void }
  def update
    if @booth.update(booth_params)
      redirect_to admin_booth_path(@booth), notice: t("flash.actions.update.poll_booth")
    else
      render :edit
    end
  end

  sig { void }
  def available
    @booths = Poll::Booth.available.order(name: :asc).page(params[:page])
    render :index
  end

  private

    sig { returns(ActionController::Parameters) }
    def booth_params
      params.require(:poll_booth).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      [:name, :location]
    end
end
