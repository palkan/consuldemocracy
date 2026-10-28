# typed: true
class Admin::NewslettersController < Admin::BaseController
  sig { void }
  def index
    @newsletters = Newsletter.all
  end

  sig { void }
  def show
    @newsletter = Newsletter.find(params[:id])
  end

  sig { void }
  def new
    @newsletter = Newsletter.new
  end

  sig { void }
  def create
    @newsletter = Newsletter.new(newsletter_params)

    if @newsletter.save
      notice = t("admin.newsletters.create_success")
      redirect_to [:admin, @newsletter], notice: notice
    else
      render :new
    end
  end

  sig { void }
  def edit
    @newsletter = Newsletter.find(params[:id])
  end

  sig { void }
  def update
    @newsletter = Newsletter.find(params[:id])

    if @newsletter.update(newsletter_params)
      redirect_to [:admin, @newsletter], notice: t("admin.newsletters.update_success")
    else
      render :edit
    end
  end

  sig { void }
  def destroy
    @newsletter = Newsletter.find(params[:id])
    @newsletter.destroy!

    redirect_to admin_newsletters_path, notice: t("admin.newsletters.delete_success")
  end

  sig { void }
  def deliver
    @newsletter = Newsletter.find(params[:id])

    if @newsletter.valid?
      @newsletter.delay.deliver
      @newsletter.update!(sent_at: Time.current)
      flash[:notice] = t("admin.newsletters.send_success")
    else
      flash[:error] = t("admin.segment_recipient.invalid_recipients_segment")
    end

    redirect_to [:admin, @newsletter]
  end

  private

    sig { returns(ActionController::Parameters) }
    def newsletter_params
      params.require(:newsletter).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      [:subject, :segment_recipient, :from, :body]
    end
end
