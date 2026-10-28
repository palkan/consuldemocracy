# typed: true
class Admin::Poll::ActivePollsController < Admin::Poll::BaseController
  include Translatable

  before_action :load_active_poll

  sig { void }
  def create
    if @active_poll.update(active_poll_params)
      redirect_to admin_polls_path, notice: t("flash.actions.update.active_poll")
    else
      render :edit
    end
  end

  sig { void }
  def edit
  end

  sig { void }
  def update
    if @active_poll.update(active_poll_params)
      redirect_to admin_polls_path, notice: t("flash.actions.update.active_poll")
    else
      render :edit
    end
  end

  private

    sig { void }
    def load_active_poll
      @active_poll = ::ActivePoll.first_or_initialize
    end

    sig { returns(ActionController::Parameters) }
    def active_poll_params
      params.require(:active_poll).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      [translation_params(ActivePoll)]
    end
end
