# typed: true
class Admin::Widget::FeedsController < Admin::BaseController
  sig { void }
  def update
    @feed = ::Widget::Feed.find(params[:id])
    @feed.update!(feed_params)

    head :ok
  end

  private

    sig { returns(ActionController::Parameters) }
    def feed_params
      params.require(:widget_feed).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      [:limit]
    end
end
