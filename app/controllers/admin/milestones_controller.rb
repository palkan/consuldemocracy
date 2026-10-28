# typed: true
class Admin::MilestonesController < Admin::BaseController
  include Translatable
  include ImageAttributes
  include DocumentAttributes

  before_action :load_milestoneable, only: [:index, :new, :create, :edit, :update, :destroy]
  before_action :load_milestone, only: [:edit, :update, :destroy]
  before_action :load_statuses, only: [:index, :new, :create, :edit, :update]
  helper_method :milestoneable_path

  sig { void }
  def index
  end

  sig { void }
  def new
    @milestone = @milestoneable.milestones.new
  end

  sig { void }
  def create
    @milestone = @milestoneable.milestones.new(milestone_params)
    if @milestone.save
      redirect_to milestoneable_path, notice: t("admin.milestones.create.notice")
    else
      render :new
    end
  end

  sig { void }
  def edit
  end

  sig { void }
  def update
    if @milestone.update(milestone_params)
      redirect_to milestoneable_path, notice: t("admin.milestones.update.notice")
    else
      render :edit
    end
  end

  sig { void }
  def destroy
    @milestone.destroy!
    redirect_to milestoneable_path, notice: t("admin.milestones.delete.notice")
  end

  private

    sig { returns(ActionController::Parameters) }
    def milestone_params
      params.require(:milestone).permit(allowed_params)
    end

    sig { returns(T::Array[T.any(Symbol, T::Hash[Symbol, T.untyped])]) }
    def allowed_params
      [
        :publication_date, :status_id,
        translation_params(Milestone),
        image_attributes: image_attributes, documents_attributes: document_attributes
      ]
    end

    sig { void }
    def load_milestoneable
      @milestoneable = milestoneable
    end

    sig { returns(T.any(Budget::Investment, Proposal, ::Legislation::Process)) }

    def milestoneable
      raise "Implement in subclass"
    end

    sig { void }
    def load_milestone
      @milestone = @milestoneable.milestones.find(params[:id])
    end

    sig { void }
    def load_statuses
      @statuses = Milestone::Status.all
    end

    sig { returns(String) }

    def milestoneable_path
      admin_polymorphic_path(@milestone.milestoneable)
    end
end
