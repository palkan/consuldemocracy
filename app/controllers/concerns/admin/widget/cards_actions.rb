# typed: true
module Admin::Widget::CardsActions
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ActionController::Base }

  abstract!

  include Translatable
  include ImageAttributes

  included do
    helper_method :form_path
  end

  sig { void }
  def new
    @card.header = header_card?
    render template: "#{cards_view_path}/new"
  end

  sig { void }
  def create
    if @card.save
      redirect_to_index
    else
      render template: "#{cards_view_path}/new"
    end
  end

  sig { void }
  def edit
    render template: "#{cards_view_path}/edit"
  end

  sig { void }
  def update
    if @card.update(card_params)
      redirect_to_index
    else
      render template: "#{cards_view_path}/edit"
    end
  end

  sig { void }
  def destroy
    @card.destroy!
    redirect_to_index
  end

  private

    sig { returns(ActionController::Parameters) }
    def card_params
      params.require(:widget_card).permit(allowed_params)
    end

    sig { returns(T::Array[T.untyped]) }
    def allowed_params
      [
        :link_url, :button_text, :button_url, :alignment, :header, :columns, :order,
        translation_params(Widget::Card),
        image_attributes: image_attributes
      ]
    end

    sig { returns(T::Boolean) }
    def header_card?
      params[:header_card].present?
    end

    sig { void }
    def redirect_to_index
      notice = t("admin.site_customization.pages.cards.#{params[:action]}.notice")

      redirect_to index_path, notice: notice
    end

    sig { returns(String) }
    def cards_view_path
      "admin/widget/cards"
    end

    sig { returns(T.nilable(String)) }
    def form_path
      nil
    end

    sig { abstract.returns(String) }
    def index_path; end
end
